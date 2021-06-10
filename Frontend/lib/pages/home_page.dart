import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'package:just_chat/socket.dart';
import '../models/chatroom.dart';
import '../models/user.dart';
import 'chat_page.dart';
import 'userProfile_page.dart';
import 'create_group_page.dart';
import 'package:just_chat/utils/connectivity.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  Box<ChatRoom> chatRoomBox = Hive.box("chatroom");
  Box<User> userBox = Hive.box("user");

  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      await Provider.of<AuthProvider>(context, listen: false).wakeUpCall();
      Socket.createAndInitializeSocket(context);
      Socket.socketIO.unSubscribesAll();
      Socket.subscribeEvents(context);
      Socket.connectViaSocket();
    });
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> openDialog() async {
    int state = 0; //0,1,2
    String email = "";
    String name = "";
    String uid = "";
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, ss) {
          return Dialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: state == 2
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Name: $name",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Email: $email",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "UID: $uid",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            "This user is now added to your contact list",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Add User",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: textController,
                            decoration: InputDecoration(
                                labelText: "Enter User's UID",
                                filled: true,
                                fillColor: Colors.white),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          state == 0
                              ? ElevatedButton(
                                  onPressed: () async {
                                    if (!await InternetConnectivity
                                        .checkNetworkConnection()) {
                                      // alertsClass.showCustomSnackBar(
                                      //     "Check your Connection!");
                                      return;
                                    }
                                    if (textController.text.trim().isEmpty) {
                                      return;
                                    }
                                    final value = userBox.values.firstWhere(
                                        (element) =>
                                            element.uid ==
                                            textController.text.trim(),
                                        orElse: () => null);
                                    if (value != null) return;
                                    ss(() => state = 1);
                                    Socket.socketIO.sendMessage(
                                        "findandadduser",
                                        json.encode(
                                          {
                                            "uid": textController.text.trim(),
                                          },
                                        ), (response) {
                                      if (response.toString() == "done") {
                                        ss(() => state = 0);
                                      }
                                      final responseData =
                                          json.decode(response);
                                      email = responseData["email"];
                                      name = responseData["name"];
                                      uid = responseData["uid"];
                                      ss(() => state = 2);
                                    });
                                  },
                                  child: Text(
                                    "Search",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                )
                              : CircularProgressIndicator(),
                        ],
                      ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserProfilePage(
                  name: Provider.of<AuthProvider>(context, listen: false).name,
                  emailId:
                      Provider.of<AuthProvider>(context, listen: false).email,
                  uid: Provider.of<AuthProvider>(context, listen: false).uid,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: chatRoomBox.listenable(),
          builder: (context, box, widget) {
            return chatRoomBox.length == 0
                ? Center(
                    child: Text(
                      "No Chats",
                      style: TextStyle(color: Colors.grey, fontSize: 30),
                    ),
                  )
                : ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatPage(index)));
                        },
                        title: Text(chatRoomBox.getAt(index).name),
                        subtitle: Text(
                            chatRoomBox.getAt(index).messages.length == 0
                                ? "No chat"
                                : chatRoomBox.getAt(index).messages.last.body),
                        trailing: chatRoomBox.getAt(index).messages.length == 0
                            ? Container(
                                width: 1,
                              )
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    DateFormat("h:mm a").format(chatRoomBox
                                        .getAt(index)
                                        .messages
                                        .last
                                        .time),
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                  chatRoomBox.getAt(index).newMessages == 0
                                      ? Container(
                                          width: 1,
                                        )
                                      : Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Colors.cyan,
//                                            borderRadius:
//                                                BorderRadius.circular(100),
                                              shape: BoxShape.circle),
                                          child: Text(
                                            chatRoomBox
                                                .getAt(index)
                                                .newMessages
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                ],
                              ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: chatRoomBox.length,
                  );
          }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 0,
            backgroundColor: Colors.black,
            onPressed: openDialog,
            label: Text("Add User"),
            icon: Icon(Icons.person_add),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            heroTag: 1,
            backgroundColor: Colors.black,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateGroupPage(),
              ),
            ),
            label: Text("Create Group"),
            icon: Icon(Icons.group_add),
          )
        ],
      ),
    );
  }
}
