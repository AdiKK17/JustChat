// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatroom.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatRoomAdapter extends TypeAdapter<ChatRoom> {
  @override
  final int typeId = 1;

  @override
  ChatRoom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatRoom()
      .._roomId = fields[0] as String
      .._name = fields[1] as String
      .._messages = (fields[2] as List)?.cast<Message>()
      .._unsentMessages = (fields[3] as List)?.cast<Message>()
      .._users = (fields[4] as List)?.cast<User>()
      .._newMessages = fields[5] as int
      .._isGroup = fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, ChatRoom obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj._roomId)
      ..writeByte(1)
      ..write(obj._name)
      ..writeByte(2)
      ..write(obj._messages)
      ..writeByte(3)
      ..write(obj._unsentMessages)
      ..writeByte(4)
      ..write(obj._users)
      ..writeByte(5)
      ..write(obj._newMessages)
      ..writeByte(6)
      ..write(obj._isGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
