import 'package:hive_flutter/hive_flutter.dart';
import 'package:wc_dart_v1/models/session_model.dart';
import 'package:wc_dart_v1/wc_dart_v1.dart';

typedef SessionRequestCallback = void Function(
  int id,
  int chainId,
  WCPeerMeta peerMeta,
  WCClient client,
);

typedef SignRequest = void Function(
  int id,
  WCSessionStore session,
  WCEthereumSignMessage ethereumSignMessage,
  WCClient client,
);

typedef SessionClosed = void Function(
  int? code,
  String? reason,
  String? key,
  WalletClientInfo info,
);

typedef SessionError = void Function(dynamic message);

typedef EthTransactionCallback = void Function(
  int id,
  WCSessionStore session,
  WCEthereumTransaction transaction,
  WCClient client,
);

typedef SwitchChain = void Function(
  int id,
  WCSessionStore session,
  int chainId,
  WCClient client,
);

class WalletConnectV1 {
  WalletConnectV1({
    required this.peerMeta,
    required this.onSessionRequest,
    required this.onSignRequest,
    required this.onSessionClosed,
    required this.onSessionError,
    required this.onSignTransaction,
    required this.onSendTransaction,
    required this.onSwitchNetwork,
  }) {
    initHive();
  }

  final WCPeerMeta peerMeta;
  final SessionRequestCallback onSessionRequest;
  final SignRequest onSignRequest;
  final SessionClosed onSessionClosed;
  final SessionError onSessionError;
  final EthTransactionCallback onSignTransaction;
  final EthTransactionCallback onSendTransaction;
  final SwitchChain onSwitchNetwork;

  SavedSessions? savedSessions;
  WCSessionStore? sessionStore;
  final List<WalletClientInfo> connectedClients = [];
  late WCClient _wcClient;
  late WCSession _wcSession;

  WCClient get currentClient => _wcClient;
  WCSession get currentClientSession => _wcSession;

  Future<void> saveSession(WCSessionStore session) async {
    if (savedSessions == null) {
      savedSessions = SavedSessions([session]);
    } else {
      savedSessions!.addSession = session;
    }
    await saveSessions();
  }

  void initHive() async {
    Hive
      ..initFlutter()
      ..registerAdapter(SavedSessionsAdapter())
      ..registerAdapter(WCSessionStoreAdapter())
      ..registerAdapter(WCSessionAdapter())
      ..registerAdapter(WCPeerMetaAdapter());
    await Hive.openBox<SavedSessions>('wallet_sessions');
    fetchSession();
    if (savedSessions?.sessions.isNotEmpty ?? false) {
      for (var session in savedSessions!.sessions) {
        await connectWithSessionStore(session);
      }
    }
  }

  Future<void> saveSessions() async {
    final Box<SavedSessions> sessionBox =
        Hive.box<SavedSessions>('wallet_sessions');
    await sessionBox.put('sessions', savedSessions!);
  }

  void fetchSession() {
    final Box<SavedSessions> sessionBox =
        Hive.box<SavedSessions>('wallet_sessions');
    savedSessions = sessionBox.get('sessions') ?? SavedSessions([]);
  }

  Future<void> connectWithUri(String uri) async {
    _wcClient = WCClient(
      onSessionRequest: _onSessionRequest,
      onFailure: _onSessionError,
      onDisconnect: _onSessionClosed,
      onEthSign: _onSign,
      onEthSignTransaction: _onSignTransaction,
      onEthSendTransaction: _onSendTransaction,
      onCustomRequest: (_, __) {},
      onConnect: _onConnect,
      onWalletSwitchNetwork: _onSwitchNetwork,
      onRequestReceived: _onRequestReceived,
    );
    _wcSession = WCSession.from(uri);
    await _wcClient.connectNewSession(session: _wcSession, peerMeta: peerMeta);
  }

  Future<void> connectWithSessionStore(WCSessionStore store) async {
    _wcClient = WCClient(
      onSessionRequest: _onSessionRequest,
      onFailure: _onSessionError,
      onDisconnect: _onSessionClosed,
      onEthSign: _onSign,
      onEthSignTransaction: _onSignTransaction,
      onEthSendTransaction: _onSendTransaction,
      onCustomRequest: (_, __) {},
      onConnect: _onConnect,
      onWalletSwitchNetwork: _onSwitchNetwork,
      onRequestReceived: _onRequestReceived,
    );
    _wcClient.connectFromSessionStore(store);
    connectedClients.add(WalletClientInfo(
      client: _wcClient,
      key: _wcClient.session!.key,
      remotePeerUrl: _wcClient.remotePeerMeta!.url,
    ));
  }

  void disconnect(WCSessionStore sessionStore) {
    for (WalletClientInfo walletClientInfo in connectedClients) {
      if (walletClientInfo.key == sessionStore.session.key) {
        _wcClient = walletClientInfo.client;
        break;
      }
    }
    connectedClients.removeWhere((element) => element.client == _wcClient);
    if (_wcClient.isConnected) {
      _wcClient.killSession();
    }
  }

  void _onSwitchNetwork(int id, int chainId) async {
    onSwitchNetwork.call(id, sessionStore!, chainId, _wcClient);
  }

  void _onConnect() {
    // TODO: wallet connected state
  }

  _onRequestReceived(String? key, WCMethod? method) {
    if (method != WCMethod.sessionRequest && connectedClients.isNotEmpty) {
      for (WalletClientInfo walletClientInfo in connectedClients) {
        if (walletClientInfo.key == key) {
          _wcClient = walletClientInfo.client;
          break;
        }
      }
      sessionStore = _wcClient.sessionStore;
    }
  }

  void _onSessionRequest(int id, int chainId, WCPeerMeta peerMeta) {
    onSessionRequest.call(id, chainId, peerMeta, _wcClient);
  }

  void _onSign(int id, WCEthereumSignMessage ethereumSignMessage) {
    onSignRequest(id, sessionStore!, ethereumSignMessage, _wcClient);
  }

  void _onSessionClosed(int? code, String? reason, String? key) {
    for (WalletClientInfo walletClientInfo in connectedClients) {
      if (!walletClientInfo.client.isConnected) {
        final sessionToRemove = savedSessions!.sessions
            .where((element) => element.session.key == walletClientInfo.key)
            .first;
        savedSessions!.removeSession = sessionToRemove;
        onSessionClosed.call(code, reason, key, walletClientInfo);
        connectedClients.remove(walletClientInfo);
        saveSessions();
        break;
      }
    }
  }

  void _onSessionError(dynamic message) {
    onSessionError.call(message);
  }

  void _onSignTransaction(int id, WCEthereumTransaction ethereumTransaction) {
    onSignTransaction.call(id, sessionStore!, ethereumTransaction, _wcClient);
  }

  void _onSendTransaction(int id, WCEthereumTransaction ethereumTransaction) {
    onSendTransaction.call(id, sessionStore!, ethereumTransaction, _wcClient);
  }
}
