import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:just_chat/socket.dart';

import '../models/user.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateGroupPage();
  }
}

class _CreateGroupPage extends State<CreateGroupPage> {
  Box<User> userBox = Hive.box("user");
  final List<String> _users = [];
  final TextEditingController roomNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> openDialog() async {
    int state = 0; //0,1,2
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
                            "Room Created",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Selected Users",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          Expanded(
                            child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return Text(
                                    userBox.get(_users[index]).name,
                                    style: TextStyle(color: Colors.white),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    height: 5,
                                  );
                                },
                                itemCount: _users.length),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: roomNameController,
                            decoration: InputDecoration(
                                labelText: 'Group Name',
                                filled: true,
                                fillColor: Colors.white),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          state == 0
                              ? ElevatedButton(
                                  onPressed: () {
                                    if (roomNameController.text
                                        .trim()
                                        .isEmpty) {
                                      return;
                                    }
                                    ss(() => state = 1);
                                    Socket.socketIO.sendMessage(
                                        "creategrouproom",
                                        json.encode(
                                          {
                                            "users": _users,
                                            "name":
                                                roomNameController.text.trim(),
                                          },
                                        ), (response) {
                                      if (response.toString() == "done") {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  },
                                  child: Text(
                                    "Create Group",
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
          title: const Text("Create Group"),
          actions: [
            Center(
                child: Text(_users.length == 0
                    ? "Select Users"
                    : "${_users.length} of 10 selected"))
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
                        selected: _users.contains(userBox.getAt(index).userId)
                            ? true
                            : false,
                        onTap: () {
                          setState(() {
                            if (_users.contains(userBox.getAt(index).userId))
                              _users.removeWhere((element) =>
                                  element == userBox.getAt(index).userId);
                            else if (_users.length == 10)
                              return;
                            else
                              _users.add(userBox.getAt(index).userId);
                          });
                        },
                        title: Text(userBox.getAt(index).name),
                        subtitle: Text(userBox.getAt(index).email),
                        trailing: _users.contains(userBox.getAt(index).userId)
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.cyan,
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
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              if (_users.length <= 1) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please choose at least 2 participants"),
                  ),
                );
                return;
              }
              openDialog();
            },
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          );
        }));
  }
}
