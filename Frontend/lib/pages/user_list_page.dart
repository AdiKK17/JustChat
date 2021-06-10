import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:just_chat/socket.dart';
import '../models/user.dart';
import 'create_group_page.dart';

class UserListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UserListPage();
  }
}

class _UserListPage extends State<UserListPage> {
  Box<User> userBox = Hive.box("user");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> openDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320.0,
                    child: RaisedButton(
                      onPressed: () {
                        //create room
                        Socket.socketIO.sendMessage(
                            "createRoom",
                            json.encode(
                              {
                                "user": userBox.getAt(index).userId,
                                "name": userBox.getAt(index).name,
                              },
                            ), (response) {
                          if (response.toString() == "done") {
//                            final user = userBox.getAt(index);
//                            user.isConnected = true;
//                            userBox.put(user.userId, user);
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Connect",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: const Color(0xFF1BC0C5),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text("Users"),
        actions: [
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.people_outline,
              color: Colors.white,
            ),
            label: ValueListenableBuilder(
                valueListenable: userBox.listenable(),
                builder: (context, box, widget) {
                  return Text(
                    userBox.length.toString(),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: userBox.listenable(),
        builder: (context, box, widget) {
          return userBox.length == 0
              ? Center(
                  child: Text(
                    "No Users",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        if (!userBox.getAt(index).isConnected)
                          openDialog(index);
                      },
                      selected: userBox.getAt(index).isConnected,
                      title: Text(userBox.getAt(index).name),
                      subtitle: Text(userBox.getAt(index).email),
                      trailing: userBox.getAt(index).isConnected
                          ? Icon(
                              Icons.sentiment_satisfied,
                              color: Colors.cyanAccent,
                            )
                          : Container(
                              width: 1,
                            ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: userBox.length,
                );
        },
      ),
      floatingActionButton: userBox.length != 0
          ? FloatingActionButton.extended(
              backgroundColor: Colors.black,
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CreateGroupPage(),
                ),
              ),
              label: Text("Create Group"),
              icon: Icon(Icons.group_add),
            )
          : Container(),
    );
  }
}
