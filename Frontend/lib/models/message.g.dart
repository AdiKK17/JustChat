// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 2;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message()
      .._fromId = fields[0] as String
      .._body = fields[1] as String
      .._time = fields[2] as DateTime
      .._type = fields[3] as String
      .._id = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj._fromId)
      ..writeByte(1)
      ..write(obj._body)
      ..writeByte(2)
      ..write(obj._time)
      ..writeByte(3)
      ..write(obj._type)
      ..writeByte(4)
      ..write(obj._id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
