import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import './models/user.dart';
import './models/chatroom.dart';
import './models/message.dart';

import './providers/auth_provider.dart';

class Socket {
  static SocketIO socketIO;
  static Box<User> userBox = Hive.box("user");
  static Box<ChatRoom> chatRoomBox = Hive.box("chatroom");

  static Future<void> createAndInitializeSocket(BuildContext context) async {
    //Creating the socket
    socketIO = SocketIOManager().createSocketIO(
        'https://justchatt.herokuapp.com/', '/',
        query:
            "userId=${Provider.of<AuthProvider>(context, listen: false).userId}&name=${Provider.of<AuthProvider>(context, listen: false).name}");

    socketIO.init();
  }

  static Future<void> connectViaSocket() async {
    await socketIO.connect();
  }

  static SocketIO getSocket() {
    return socketIO;
  }

  static void subscribeEvents(BuildContext context) {
    //receive new users through this subscribe at the start of connection
    socketIO.subscribe(
      'get_users',
      (jsonData) {
        Map<String, dynamic> data = json.decode(jsonData);
        print(data);
        final users = data["users"].map((item) => User.fromJson(item)).toList();
        users.forEach((u) {
          userBox.put(u.userId, u);
        });
        print(userBox.length);
        print("New Users set!!");
      },
    );

    //receive a new user through this subscribe whenever you are also connected to the server
    socketIO.subscribe(
      'new_user',
      (jsonData) {
        Map<String, dynamic> data = json.decode(jsonData);
        print(data);
        final user = User.fromJson(data);
        userBox.put(user.userId, user);
        print(userBox.length);
        print("New User set!!");
      },
    );

    //receive a new chatroom through this subscribe whenever you create a room
    //receive a new chatroom through this subscribe whenever you are also connected to the server
    socketIO.subscribe(
      'new_chatroom',
      (jsonData) {
        Map<String, dynamic> data = json.decode(jsonData);
        print(data);
        final chatroom = ChatRoom.fromJson(data["room"],
            Provider.of<AuthProvider>(context, listen: false).userId);
        chatRoomBox.put(chatroom.roomId, chatroom);
        print(chatRoomBox.length);
        print("New Chatroom set!!");
      },
    );

    //receive a new chatroom through this subscribe whenever you create a room
    socketIO.subscribe(
      'get_chatrooms',
      (jsonData) {
        Map<String, dynamic> data = json.decode(jsonData);
        print(data);
        final chatrooms = data["chatrooms"]
            .map((item) => ChatRoom.fromJson(
                item, Provider.of<AuthProvider>(context, listen: false).userId))
            .toList();
        chatrooms.forEach((room) {
          chatRoomBox.put(room.roomId, room);
        });
        print(chatRoomBox.length);
        print("New Chatrooms set!!");
      },
    );

    //receive messages while connected
    socketIO.subscribe('new_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      print(data);
      final message = Message.fromJson(data["message"]);
      final ChatRoom chatroom = chatRoomBox.get(data["message"]["room"]);
      chatroom.messages.add(message);
      chatroom.newMessages++;
      chatRoomBox.put(chatroom.roomId, chatroom);
      print("New Message set!!");
    });

    //receive messages
    socketIO.subscribe('get_messages', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      print(data);
      data["messages"].forEach((msg) {
        final message = Message.fromJson(msg);
        final ChatRoom chatroom = chatRoomBox.get(msg["room"]);
        chatroom.messages.add(message);
        chatroom.newMessages++;
        chatRoomBox.put(chatroom.roomId, chatroom);
      });
      print("New Messages set!!");
    });
  }
}
