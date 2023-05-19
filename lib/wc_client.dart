import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'models/exception/exceptions.dart';
import 'models/jsonrpc/json_rpc_error.dart';
import 'models/jsonrpc/json_rpc_error_response.dart';
import 'models/jsonrpc/json_rpc_request.dart';
import 'models/jsonrpc/json_rpc_response.dart';
import 'models/message_type.dart';
import 'models/session/wc_approve_session_response.dart';
import 'models/session/wc_session_request.dart';
import 'models/session/wc_session_update.dart';
import 'models/wc_encryption_payload.dart';
import 'models/wc_socket_message.dart';
import 'wc_cipher.dart';
import 'wc_dart_v1.dart';

typedef SessionRequest = void Function(
    int id, int chainId, WCPeerMeta peerMeta);
typedef SocketError = void Function(dynamic message);
typedef SocketClose = void Function(int? code, String? reason, String? key);
typedef EthSign = void Function(int id, WCEthereumSignMessage message);
typedef EthTransaction = void Function(
    int id, WCEthereumTransaction transaction);
typedef CustomRequest = void Function(int id, String payload);
typedef WalletSwitchNetwork = void Function(int id, int chainId);

class WCClient {
  late WebSocketChannel _webSocket;
  Stream _socketStream = const Stream.empty();

  // ignore: close_sinks
  WebSocketSink? _socketSink;
  WCSession? _session;
  WCPeerMeta? _peerMeta;
  WCPeerMeta? _remotePeerMeta;
  int _handshakeId = -1;
  int? _chainId;
  String? _peerId;
  String? _remotePeerId;
  bool _isConnected = false;

  WCClient(
      {this.onSessionRequest,
      this.onFailure,
      this.onDisconnect,
      this.onEthSign,
      this.onEthSignTransaction,
      this.onEthSendTransaction,
      this.onWalletSwitchNetwork,
      this.onCustomRequest,
      this.onConnect,
      this.onRequestReceived});

  final SessionRequest? onSessionRequest;
  final SocketError? onFailure;
  final SocketClose? onDisconnect;
  final EthSign? onEthSign;
  final EthTransaction? onEthSignTransaction, onEthSendTransaction;
  final CustomRequest? onCustomRequest;
  final WalletSwitchNetwork? onWalletSwitchNetwork;
  final Function()? onConnect;
  final Function(String?, WCMethod?)? onRequestReceived;

  WCSession? get session => _session;

  WCPeerMeta? get peerMeta => _peerMeta;

  WCPeerMeta? get remotePeerMeta => _remotePeerMeta;

  int? get chainId => _chainId;

  String? get peerId => _peerId;

  String? get remotePeerId => _remotePeerId;

  bool get isConnected => _isConnected;

  Future<void> connectNewSession({
    required WCSession session,
    required WCPeerMeta peerMeta,
    HttpClient? customHttpClient,
  }) async {
    await _connect(
      session: session,
      peerMeta: peerMeta,
      customClient: customHttpClient,
    );
  }

  Future<void> connectFromSessionStore(
    WCSessionStore sessionStore, {
    HttpClient? customHttpClient,
  }) async {
    await _connect(
      fromSessionStore: true,
      session: sessionStore.session,
      peerMeta: sessionStore.peerMeta,
      remotePeerMeta: sessionStore.remotePeerMeta,
      peerId: sessionStore.peerId,
      remotePeerId: sessionStore.remotePeerId,
      chainId: sessionStore.chainId,
      customClient: customHttpClient,
    );
  }

  WCSessionStore get sessionStore => WCSessionStore(
        session: _session!,
        peerMeta: _peerMeta!,
        peerId: _peerId!,
        remotePeerId: _remotePeerId!,
        remotePeerMeta: _remotePeerMeta!,
        chainId: _chainId!,
      );

  approveSession({required List<String> accounts, int? chainId}) {
    if (_handshakeId <= 0) {
      throw HandshakeException();
    }

    if (chainId != null) _chainId = chainId;
    final result = WCApproveSessionResponse(
      chainId: _chainId,
      accounts: accounts,
      peerId: _peerId!,
      peerMeta: _peerMeta!,
    );
    final response = JsonRpcResponse<Map<String, dynamic>>(
      id: _handshakeId,
      result: result.toJson(),
    );
    // print('approveSession ${jsonEncode(response.toJson())}');
    onConnect?.call();
    _encryptAndSend(jsonEncode(response.toJson()));
  }

  Future<void> updateSession({
    List<String>? accounts,
    int? chainId,
    bool approved = true,
  }) async {
    _chainId = chainId ?? _chainId;
    final param = WCSessionUpdate(
      approved: approved,
      chainId: _chainId,
      accounts: accounts,
    );
    final request = JsonRpcRequest(
      id: DateTime.now().millisecondsSinceEpoch,
      method: WCMethod.sessionUpdate,
      params: [param.toJson()],
    );
    return _encryptAndSend(jsonEncode(request.toJson()));
  }

  rejectSession({String message = "Session rejected"}) {
    if (_handshakeId <= 0) {
      throw HandshakeException();
    }

    final response = JsonRpcErrorResponse(
      id: _handshakeId,
      error: JsonRpcError.serverError(message),
    );
    _encryptAndSend(jsonEncode(response.toJson()));
  }

  approveRequest<T>({
    required int id,
    required T result,
  }) {
    final response = JsonRpcResponse<T>(
      id: id,
      result: result,
    );
    _encryptAndSend(jsonEncode(response.toJson()));
  }

  rejectRequest({
    required int id,
    String message = "Reject by the user",
  }) {
    final response = JsonRpcErrorResponse(
      id: id,
      error: JsonRpcError.serverError(message),
    );
    _encryptAndSend(jsonEncode(response.toJson()));
  }

  _connect({
    required WCSession session,
    required WCPeerMeta peerMeta,
    bool fromSessionStore = false,
    WCPeerMeta? remotePeerMeta,
    String? peerId,
    String? remotePeerId,
    int? chainId,
    HttpClient? customClient,
  }) async {
    if (session == WCSession(topic: '', version: '', bridge: '', key: '')) {
      throw InvalidSessionException();
    }

    peerId ??= const Uuid().v4();
    _session = session;
    _peerMeta = peerMeta;
    _remotePeerMeta = remotePeerMeta;
    _peerId = peerId;
    _remotePeerId = remotePeerId;
    _chainId = chainId;
    final bridgeUri =
        Uri.parse(session.bridge.replaceAll('https://', 'wss://'));
    final ws = await WebSocket.connect(
      bridgeUri.toString(),
      customClient: customClient,
    );
    _webSocket = IOWebSocketChannel(ws);
    _isConnected = true;
    if (fromSessionStore) {
      onConnect?.call();
    }
    _socketStream = _webSocket.stream;
    _socketSink = _webSocket.sink;
    _listen();
    _subscribe(session.topic);
    _subscribe(peerId);
  }

  disconnect() {
    _socketSink!.close(WebSocketStatus.normalClosure);
  }

  _subscribe(String topic) {
    final message = WCSocketMessage(
      topic: topic,
      type: MessageType.sub,
      payload: '',
    ).toJson();
    _socketSink!.add(jsonEncode(message));
  }

  _invalidParams(int id) {
    final response = JsonRpcErrorResponse(
      id: id,
      error: JsonRpcError.invalidParams("Invalid parameters"),
    );
    _encryptAndSend(jsonEncode(response.toJson()));
  }

  Future<void> _encryptAndSend(String result) async {
    final payload = await WCCipher.encrypt(result, _session!.key);
    // print('encrypted $payload');
    final message = WCSocketMessage(
      topic: _remotePeerId ?? _session!.topic,
      type: MessageType.pub,
      payload: jsonEncode(payload.toJson()),
    );
    // print('message ${jsonEncode(message.toJson())}');
    _socketSink!.add(jsonEncode(message.toJson()));
  }

  _listen() {
    _socketStream.listen(
      (event) async {
        // print('DATA: $event ${event.runtimeType}');
        // final Map<String, dynamic> decoded = json.decode("$event");
        // print('DECODED: $decoded ${decoded.runtimeType}');
        final socketMessage = WCSocketMessage.fromJson(jsonDecode("$event"));
        final decryptedMessage = await _decrypt(socketMessage);
        _handleMessage(decryptedMessage);
      },
      onError: (error) {
        // print('onError $_isConnected CloseCode ${_webSocket.closeCode} $error');
        _resetState();
        onFailure?.call('$error');
      },
      onDone: () {
        if (_isConnected) {
          final key = _session!.key;
          // print('onDone $_isConnected CloseCode ${_webSocket.closeCode} ${_webSocket.closeReason}');
          _resetState();
          onDisconnect?.call(_webSocket.closeCode, _webSocket.closeReason, key);
        }
      },
    );
  }

  Future<String> _decrypt(WCSocketMessage socketMessage) async {
    final payload =
        WCEncryptionPayload.fromJson(jsonDecode(socketMessage.payload));
    final decrypted = await WCCipher.decrypt(payload, _session!.key);
    // print("DECRYPTED: $decrypted");
    return decrypted;
  }

  _handleMessage(String payload) {
    try {
      final request = JsonRpcRequest.fromJson(jsonDecode(payload));
      if (request.method != null) {
        _handleRequest(request);
      } else {
        onCustomRequest?.call(request.id, payload);
      }
    } on InvalidJsonRpcParamsException catch (e) {
      _invalidParams(e.requestId);
    }
  }

  _handleRequest(JsonRpcRequest request) {
    if (request.params == null) throw InvalidJsonRpcParamsException(request.id);
    onRequestReceived?.call(_session?.key, request.method);
    switch (request.method) {
      case WCMethod.sessionRequest:
        final param = WCSessionRequest.fromJson(request.params!.first);
        // print('SESSION_REQUEST $param');
        _handshakeId = request.id;
        _remotePeerId = param.peerId;
        _remotePeerMeta = param.peerMeta;
        _chainId = param.chainId;
        onSessionRequest?.call(request.id, param.chainId ?? 1, param.peerMeta);
        break;
      case WCMethod.sessionUpdate:
        final param = WCSessionUpdate.fromJson(request.params!.first);
        // print('SESSION_UPDATE $param');
        if (!param.approved) {
          killSession();
        }
        break;
      case WCMethod.ethSign:
        // print('ETH_SIGN $request');
        final params = request.params!.cast<String>();
        if (params.length < 2) {
          throw InvalidJsonRpcParamsException(request.id);
        }

        onEthSign?.call(
          request.id,
          WCEthereumSignMessage(
            raw: params,
            type: WCSignType.message,
          ),
        );
        break;
      case WCMethod.ethPersonalSign:
        // print('ETH_PERSONAL_SIGN $request');
        final params = request.params!.cast<String>();
        if (params.length < 2) {
          throw InvalidJsonRpcParamsException(request.id);
        }

        onEthSign?.call(
          request.id,
          WCEthereumSignMessage(
            raw: params,
            type: WCSignType.personalMessage,
          ),
        );
        break;
      case WCMethod.ethSignTypedData:
        // print('ETH_SIGN_TYPE_DATA $request');
        final params = request.params!.cast<String>();
        if (params.length < 2) {
          throw InvalidJsonRpcParamsException(request.id);
        }

        onEthSign?.call(
          request.id,
          WCEthereumSignMessage(
            raw: params,
            type: WCSignType.typedMessage,
          ),
        );
        break;
      case WCMethod.ethSignTransaction:
        // print('ETH_SIGN_TRANSACTION $request');
        final param = WCEthereumTransaction.fromJson(request.params!.first);
        onEthSignTransaction?.call(request.id, param);
        break;
      case WCMethod.ethSendTransaction:
        // print('ETH_SEND_TRANSACTION $request');
        final param = WCEthereumTransaction.fromJson(request.params!.first);
        onEthSendTransaction?.call(request.id, param);
        break;
      case WCMethod.walletSwitchNetwork:
        // print('WALLET_SWITCH_NETWORK $request');
        final params = WCWalletSwitchNetwork.fromJson(request.params!.first);
        onWalletSwitchNetwork?.call(request.id, int.parse(params.chainId));
        break;
      default:
    }
  }

  killSession() async {
    await updateSession(approved: false);
    // Future.delayed(const Duration(seconds: 2)).then((value) => disconnect());
    disconnect();
  }

  _resetState() {
    _handshakeId = -1;
    _isConnected = false;
    _session = null;
    _peerId = null;
    _chainId = null;
    _remotePeerId = null;
    _remotePeerMeta = null;
    _peerMeta = null;
  }
}
