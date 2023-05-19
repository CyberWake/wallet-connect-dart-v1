// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wc_session_store.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WCSessionStoreAdapter extends TypeAdapter<WCSessionStore> {
  @override
  final int typeId = 0;

  @override
  WCSessionStore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WCSessionStore(
      session: fields[0] as WCSession,
      peerMeta: fields[1] as WCPeerMeta,
      remotePeerMeta: fields[2] as WCPeerMeta,
      chainId: fields[3] as int,
      peerId: fields[4] as String,
      remotePeerId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WCSessionStore obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.session)
      ..writeByte(1)
      ..write(obj.peerMeta)
      ..writeByte(2)
      ..write(obj.remotePeerMeta)
      ..writeByte(3)
      ..write(obj.chainId)
      ..writeByte(4)
      ..write(obj.peerId)
      ..writeByte(5)
      ..write(obj.remotePeerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WCSessionStoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

WCSessionStore _$WCSessionStoreFromJson(Map<String, dynamic> json) =>
    WCSessionStore(
      session: WCSession.fromJson(json['session'] as Map<String, dynamic>),
      peerMeta: WCPeerMeta.fromJson(json['peerMeta'] as Map<String, dynamic>),
      remotePeerMeta:
          WCPeerMeta.fromJson(json['remotePeerMeta'] as Map<String, dynamic>),
      chainId: json['chainId'] as int,
      peerId: json['peerId'] as String,
      remotePeerId: json['remotePeerId'] as String,
    );

Map<String, dynamic> _$WCSessionStoreToJson(WCSessionStore instance) =>
    <String, dynamic>{
      'session': instance.session,
      'peerMeta': instance.peerMeta,
      'remotePeerMeta': instance.remotePeerMeta,
      'chainId': instance.chainId,
      'peerId': instance.peerId,
      'remotePeerId': instance.remotePeerId,
    };
