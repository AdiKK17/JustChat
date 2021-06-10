import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:just_chat/providers/auth_provider.dart';
import 'package:just_chat/socket.dart';
import '../models/chatroom.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'userprofile_page.dart';

class ChatPage extends StatefulWidget {
  final int index;

  ChatPage(this.index);

  @override
  State<StatefulWidget> createState() {
    return _ChatPage();
  }
}

class _ChatPage extends State<ChatPage> {
  Box<ChatRoom> chatRoomBox = Hive.box("chatroom");
  Box<User> userBox = Hive.box("user");
  bool showFab = false;

  TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    final chatRoom = chatRoomBox.getAt(widget.index);
    chatRoom.newMessages = 0;
    chatRoomBox.putAt(widget.index, chatRoom);

    _scrollController?.dispose();
    _textController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _textController.addListener(() {
      if (_textController.text.trim() == '') {
        if (showFab == true)
          setState(() {
            showFab = false;
          });
      } else {
        if (showFab == false)
          setState(() {
            showFab = true;
          });
      }
    });

    final chatRoom = chatRoomBox.getAt(widget.index);
    chatRoom.newMessages = 0;
    chatRoomBox.putAt(widget.index, chatRoom);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(0.0,
          duration: Duration.zero, curve: Curves.easeIn);
    });

    chatRoomBox.getAt(widget.index).unsentMessages.forEach((element) {
      Socket.socketIO.sendMessage(
          'message',
          json.encode({
            'roomId': chatRoomBox.getAt(widget.index).roomId,
            'body': element.body,
            'type': "text"
          }), (response) {
        Map<String, dynamic> data = json.decode(response);
        final chatRoom = chatRoomBox.getAt(widget.index);
        final ind = chatRoom.unsentMessages
            .indexWhere((element) => element.body == data["body"]);
        final message = chatRoom.unsentMessages.removeAt(ind);
        message.id = data["id"];
        chatRoom.messages.add(message);
        chatRoomBox.putAt(widget.index, chatRoom);
      });
    });

    print(chatRoomBox.getAt(widget.index).roomId);
    super.initState();
  }

  Widget sentMessagesList() {
    return ListView.separated(
      reverse: true,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: chatRoomBox.getAt(widget.index).messages.length,
      itemBuilder: (BuildContext context, int i) {
        return Column(
          crossAxisAlignment: chatRoomBox
                      .getAt(widget.index)
                      .messages[
                          chatRoomBox.getAt(widget.index).messages.length -
                              1 -
                              i]
                      .fromId ==
                  Provider.of<AuthProvider>(context).userId
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              child: Card(
                shape: chatRoomBox
                            .getAt(widget.index)
                            .messages[chatRoomBox
                                    .getAt(widget.index)
                                    .messages
                                    .length -
                                1 -
                                i]
                            .fromId ==
                        Provider.of<AuthProvider>(context).userId
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      )
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                color: Colors.black,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 15, top: 5, right: 10, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          chatRoomBox
                              .getAt(widget.index)
                              .users
                              .firstWhere((element) =>
                                  element.userId ==
                                  chatRoomBox
                                      .getAt(widget.index)
                                      .messages[chatRoomBox
                                              .getAt(widget.index)
                                              .messages
                                              .length -
                                          1 -
                                          i]
                                      .fromId)
                              .email,
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ),
                      Text(
                        chatRoomBox
                            .getAt(widget.index)
                            .messages[chatRoomBox
                                    .getAt(widget.index)
                                    .messages
                                    .length -
                                1 -
                                i]
                            .body,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          DateFormat("h:mm a").format(chatRoomBox
                              .getAt(widget.index)
                              .messages[chatRoomBox
                                      .getAt(widget.index)
                                      .messages
                                      .length -
                                  1 -
                                  i]
                              .time),
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                      Container(
                        child: Text(
                          DateFormat("yMMMd").format(chatRoomBox
                              .getAt(widget.index)
                              .messages[chatRoomBox
                                      .getAt(widget.index)
                                      .messages
                                      .length -
                                  1 -
                                  i]
                              .time),
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (context, i) => Container(
        width: double.infinity,
      ),
    );
  }

  Widget unsentMessagesList() {
    return ListView.separated(
      reverse: true,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: chatRoomBox.getAt(widget.index).unsentMessages.length,
      itemBuilder: (BuildContext context, int i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Card(
              color: Colors.black,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chatRoomBox
                          .getAt(widget.index)
                          .unsentMessages[chatRoomBox
                                  .getAt(widget.index)
                                  .unsentMessages
                                  .length -
                              1 -
                              i]
                          .body,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (context, i) => Container(
        width: double.infinity,
        height: 1,
      ),
    );
  }

  Widget buildMessageList() {
    return ValueListenableBuilder(
      valueListenable: chatRoomBox.listenable(),
      builder: (context, box, wid) {
        return ListView(
          reverse: true,
          controller: _scrollController,
          children: [
            unsentMessagesList(),
            sentMessagesList(),
          ],
        );
      },
    );
  }

  Widget _buildChatInput() {
    return Expanded(
      child: TextField(
        controller: _textController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: InputDecoration.collapsed(hintText: "Message..."),
      ),
    );
  }

  Widget buildSendButton() {
    return Opacity(
      opacity: showFab ? 1 : 0,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.black,
        onPressed: () {
          if (_textController.text.trim().isNotEmpty) {
            final message = Message(
              fromId: Provider.of<AuthProvider>(context, listen: false).userId,
              body: _textController.text.trim(),
              time: DateTime.now(),
            );

            final chatRoom = chatRoomBox.getAt(widget.index);
            chatRoom.unsentMessages.add(message); //add message
            chatRoomBox.putAt(widget.index, chatRoom);

            Socket.socketIO.sendMessage(
                'message',
                json.encode({
                  'roomId': chatRoomBox.getAt(widget.index).roomId,
                  'body': _textController.text.trim(),
                  'type': "text"
                }), (response) {
              Map<String, dynamic> data = json.decode(response);
              final chatRoom = chatRoomBox.getAt(widget.index);
              final ind = chatRoom.unsentMessages
                  .indexWhere((element) => element.body == data["body"]);
              final message = chatRoom.unsentMessages.removeAt(ind);
              message.id = data["id"];
              chatRoom.messages.add(message);
              chatRoomBox.putAt(widget.index, chatRoom);
            });

            _textController.text = '';
            _scrollController.animateTo(
              0.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          }
        },
        child: Icon(
          Icons.send,
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
      padding: EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          border: Border.all(
              color: Colors.black, width: 1, style: BorderStyle.solid)),
      child: Row(
        children: <Widget>[
          _buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  //completed
  Widget customDrawer() {
    return Drawer(
      child: Center(
        child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) => ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                        name: chatRoomBox.getAt(widget.index).users[index].name,
                        emailId:
                            chatRoomBox.getAt(widget.index).users[index].email,
                        uid: chatRoomBox.getAt(widget.index).users[index].uid,
                      ),
                    ),
                  ),
                  title:
                      Text(chatRoomBox.getAt(widget.index).users[index].name),
                  subtitle:
                      Text(chatRoomBox.getAt(widget.index).users[index].email),
                ),
            separatorBuilder: (context, index) => SizedBox(
                  height: 0,
                ),
            itemCount: chatRoomBox.getAt(widget.index).users.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black54,
        title: Text(
          chatRoomBox.getAt(widget.index).name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          chatRoomBox.getAt(widget.index).isGroup
              ? Builder(builder: (context) {
                  return InkWell(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: Center(
                      child: Text(
                        "${chatRoomBox.getAt(widget.index).users.length} Participants",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                })
              : Container()
        ],
      ),
      endDrawer: customDrawer(),
      endDrawerEnableOpenDragGesture: chatRoomBox.getAt(widget.index).isGroup,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      tileMode: TileMode.clamp,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color(0xffE2E2E2),
                    Color(0xffC9D6FF),
                  ])),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: buildMessageList(),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 100),
            color: Color(0xffC9D6FF),
            child: _buildInputArea(),
          ),
        ],
      ),
    );
  }
}
