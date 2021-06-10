import 'package:flutter/material.dart';
import 'package:share/share.dart';

class UserProfilePage extends StatelessWidget {
  final String name;
  final String emailId;
  final String uid;

  UserProfilePage({this.name, this.emailId, this.uid});

  Widget buildTile(String title, String trail, VoidCallback cb) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(trail),
      onTap: cb,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          buildTile("Name:", this.name, () => null),
          buildTile("Email-Id:", this.emailId, () => null),
          buildTile(
            "UID:",
            this.uid,
            () => Share.share(this.uid),
          ),
        ],
      ),
    );
  }
}
