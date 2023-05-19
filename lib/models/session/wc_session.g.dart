// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wc_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WCSessionAdapter extends TypeAdapter<WCSession> {
  @override
  final int typeId = 3;

  @override
  WCSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WCSession(
      topic: fields[0] as String,
      version: fields[1] as String,
      bridge: fields[2] as String,
      key: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WCSession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.topic)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.bridge)
      ..writeByte(3)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WCSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

WCSession _$WCSessionFromJson(Map<String, dynamic> json) => WCSession(
      topic: json['topic'] as String,
      version: json['version'] as String,
      bridge: json['bridge'] as String,
      key: json['key'] as String,
    );

Map<String, dynamic> _$WCSessionToJson(WCSession instance) => <String, dynamic>{
      'topic': instance.topic,
      'version': instance.version,
      'bridge': instance.bridge,
      'key': instance.key,
    };
