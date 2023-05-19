// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedSessionsAdapter extends TypeAdapter<SavedSessions> {
  @override
  final int typeId = 1;

  @override
  SavedSessions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedSessions(
      (fields[0] as List).cast<WCSessionStore>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedSessions obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.sessions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedSessionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
