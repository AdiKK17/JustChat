import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 2)
class Message {
  @HiveField(0)
  String _fromId;
  @HiveField(1)
  String _body;
  @HiveField(2)
  DateTime _time;
  @HiveField(3)
  String _type;
  @HiveField(4)
  String _id;

  Message({
    String id,
    String fromId,
    String body,
    DateTime time,
    String type,
  }) {
    this._id = id;
    this._fromId = fromId;
    this._body = body;
    this._time = time;
    this._type = type;
  }

  String get id => _id;
  String get fromId => _fromId;
  String get body => _body;
  DateTime get time => _time;
  String get type => _type;

  set id(String id) {
    this._id = id;
  }

  Message.fromJson(Map<String, dynamic> json) {
    _id = json["_id"];
    _fromId = json["fromId"];
    _body = json["body"];
    _type = json["type"];
    _time = DateTime.parse(json["time"]).toLocal();
  }
}
