import 'package:wc_dart_v1/wc_client.dart';

class WalletClientInfo {
  final WCClient client;
  final String remotePeerUrl;
  final String key;

  WalletClientInfo(
      {required this.client, required this.remotePeerUrl, required this.key});
}
