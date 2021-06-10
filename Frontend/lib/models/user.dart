import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String _userId;
  @HiveField(1)
  String _name;
  @HiveField(2)
  String _email;
  @HiveField(3)
  String _uid;
  @HiveField(4)
  bool _isConnected;

  User(
      {String userId,
      bool isConnected,
      String email,
      String name,
      String uid}) {
    this._userId = userId;
    this._isConnected = isConnected;
    this._name = name;
    this._email = email;
    this._uid = uid;
  }

  String get userId => _userId;
  bool get isConnected => _isConnected;
  String get name => _name;
  String get email => _email;
  String get uid => _uid;

  set id(String id) {
    this._userId = id;
  }

  set name(String name) {
    this._name = name;
  }

  set email(String email) {
    this._email = email;
  }

  set isConnected(bool isConnected) {
    this._isConnected = isConnected;
  }

  set uid(String uid) {
    this._uid = uid;
  }

  User.fromJson(Map<String, dynamic> json) {
    _userId = json['_id'];
    _name = json['name'];
    _email = json['email'];
    _uid = json['uid'];
    _isConnected = false;
  }

//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = Map<String, dynamic>();
//    data['name'] = _name;
//    data['email'] = _email;
//    data['is_verified'] = _isConnected;
//    return data;
//  }

  @override
  String toString() => 'User ID : $_userId, Name : $_name';
}
