// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wc_peer_meta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WCPeerMetaAdapter extends TypeAdapter<WCPeerMeta> {
  @override
  final int typeId = 4;

  @override
  WCPeerMeta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WCPeerMeta(
      name: fields[0] as String,
      url: fields[1] as String,
      description: fields[2] as String,
      icons: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WCPeerMeta obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WCPeerMetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

WCPeerMeta _$WCPeerMetaFromJson(Map<String, dynamic> json) => WCPeerMeta(
      name: json['name'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      icons:
          (json['icons'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$WCPeerMetaToJson(WCPeerMeta instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'description': instance.description,
      'icons': instance.icons,
    };
