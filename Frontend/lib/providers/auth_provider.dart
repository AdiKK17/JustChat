import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  String _userId;
  String _email;
  String _name;
  String _uid;

  String get email {
    return _email;
  }

  String get name {
    return _name;
  }

  String get userId {
    return _userId;
  }

  String get uid {
    return _uid;
  }

  final ngrokUrl = "https://justchatt.herokuapp.com";

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("An error Occured!"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> wakeUpCall() async {
    final response = await http.get(Uri.parse("$ngrokUrl"),
        headers: {"Content-type": "application/json"});
    print(response.body);
  }

  Future<void> setVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _userId = prefs.getString("userId");
    _email = prefs.getString("email");
    _name = prefs.getString("name");
    _uid = prefs.getString("uid");
  }

  Future<bool> signUp(
      BuildContext context, String name, String email, String password) async {
    try {
      final response = await http.post(Uri.parse("$ngrokUrl/user/signup"),
          body: json.encode(
            {
              "name": name,
              "email": email,
              "password": password,
            },
          ),
          headers: {"Content-type": "application/json"});

      final responseData = json.decode(response.body);

      if (responseData["error"] != null) {
        _showErrorDialog(context, responseData["error"]);
        return false;
      }
      _userId = responseData["result"]["_id"];
      _email = responseData["result"]["email"];
      _name = responseData["result"]["name"];
      _uid = responseData["result"]["uid"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", _userId);
      prefs.setString("email", _email);
      prefs.setString("name", _name);
      prefs.setString("uid", _uid);
      prefs.setString("isLoggedIn", "yes");
      return true;
    } catch (e) {
      return false;
    }
  }
}
