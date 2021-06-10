import 'package:hive/hive.dart';
import 'message.dart';
import 'user.dart';

part 'chatroom.g.dart';

@HiveType(typeId: 1)
class ChatRoom extends HiveObject {
  @HiveField(0)
  String _roomId;
  @HiveField(1)
  String _name;
  @HiveField(2)
  List<Message> _messages;
  @HiveField(3)
  List<Message> _unsentMessages;
  @HiveField(4)
  List<User> _users;
  @HiveField(5)
  int _newMessages;
  @HiveField(6)
  bool _isGroup;

  ChatRoom({
    String roomId,
    String name,
    List<Message> messages,
    List<Message> unsentMessages,
    List<User> users,
    int newMessages,
    bool isGroup,
  }) {
    this._roomId = roomId;
    this._name = name;
    this._messages = messages;
    this._unsentMessages = messages;
    this._users = users;
    this._newMessages = newMessages;
    this._isGroup = isGroup;
  }

  String get roomId => _roomId;
  String get name => _name;
  List<Message> get messages => _messages;
  List<Message> get unsentMessages => _unsentMessages;
  List<User> get users => _users;
  int get newMessages => _newMessages;
  bool get isGroup => _isGroup;

  set roomId(String id) {
    this._roomId = id;
  }

  set name(String name) {
    this._name = name;
  }

  set messages(List<Message> messages) {
    this._messages = messages;
  }

  set unsentMessages(List<Message> messages) {
    this._unsentMessages = unsentMessages;
  }

  set users(List<User> users) {
    this._users = users;
  }

  set newMessages(int messages) {
    this._newMessages = messages;
  }

  set isGroup(bool isGroup) {
    this._isGroup = isGroup;
  }

  ChatRoom.fromJson(Map<String, dynamic> json, String myId) {
    final users = json["users"] as List;

    _roomId = json["_id"];
    _isGroup = json["is_group"];
    _users = users.map((u) => User.fromJson(u)).toList();
    if (_isGroup) {
      _name = json["room_name"];
    } else {
      _name = _users.firstWhere((element) => element.userId != myId).email;
    }
    _messages = [];
    _unsentMessages = [];
    _newMessages = 0;
  }

  @override
  String toString() => 'User ID : $_roomId, Name : $_name';
}
