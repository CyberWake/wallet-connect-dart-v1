import 'package:hive_flutter/adapters.dart';

import 'wc_dart_v1.dart';

part 'wc_session_store.g.dart';

// @JsonSerializable()
@HiveType(typeId: 0)
class WCSessionStore {
  @HiveField(0)
  final WCSession session;
  @HiveField(1)
  final WCPeerMeta peerMeta;
  @HiveField(2)
  final WCPeerMeta remotePeerMeta;
  @HiveField(3)
  final int chainId;
  @HiveField(4)
  final String peerId;
  @HiveField(5)
  final String remotePeerId;

  WCSessionStore({
    required this.session,
    required this.peerMeta,
    required this.remotePeerMeta,
    required this.chainId,
    required this.peerId,
    required this.remotePeerId,
  });

  factory WCSessionStore.empty() => WCSessionStore(
        session: WCSession.empty(),
        peerMeta: WCPeerMeta.empty(),
        remotePeerMeta: WCPeerMeta.empty(),
        chainId: 0,
        peerId: '',
        remotePeerId: '',
      );

  factory WCSessionStore.fromJson(Map<String, dynamic> json) =>
      _$WCSessionStoreFromJson(json);

  Map<String, dynamic> toJson() => _$WCSessionStoreToJson(this);

  @override
  String toString() {
    return 'WCSessionStore(session: $session, peerMeta: $peerMeta, peerId: $peerId, remotePeerId: $remotePeerId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WCSessionStore &&
        other.session == session &&
        other.peerMeta == peerMeta &&
        other.remotePeerMeta == remotePeerMeta &&
        other.chainId == chainId &&
        other.peerId == peerId &&
        other.remotePeerId == remotePeerId;
  }

  @override
  int get hashCode {
    return session.hashCode ^
        peerMeta.hashCode ^
        remotePeerMeta.hashCode ^
        chainId.hashCode ^
        peerId.hashCode ^
        remotePeerId.hashCode;
  }
}
