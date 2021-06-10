import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_page.dart';

class AuthenticationPage extends StatefulWidget {
  final bool againLogging;

  AuthenticationPage({this.againLogging = false});

  @override
  State<StatefulWidget> createState() {
    return _AuthenticationPage();
  }
}

class _AuthenticationPage extends State<AuthenticationPage> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  final Map<String, dynamic> _formData = {
    "email": null,
    "password": null,
    "name": null,
  };

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Name', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a Name';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['name'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password invalid';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

//  Widget _buildPasswordConfirmTextField() {
//    return TextFormField(
//      decoration: InputDecoration(
//          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
//      obscureText: true,
//      validator: (String value) {
//        if (_passwordTextController.text.trim() != value) {
//          return 'Passwords do not match.';
//        }
//        return null;
//      },
//    );
//  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
        // color: Colors.black87,
        child: Text(
          "SIGNUP",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _submitForm();
        });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    Provider.of<AuthProvider>(context, listen: false)
        .signUp(context, _formData["name"], _formData["email"],
            _formData["password"])
        .then((value) {
      setState(() {
        _isLoading = false;
      });
      if (value) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "JustChat",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 50),
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
                Container(
                  child: _buildUsernameTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: _buildEmailTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: _buildPasswordTextField(),
                  width: deviceWidth * 0.85,
                ),
//                SizedBox(
//                  height: 10,
//                ),
//                Container(
//                  child: _buildPasswordConfirmTextField(),
//                  width: deviceWidth * 0.85,
//                ),
                SizedBox(
                  height: 25,
                ),
                _isLoading == true
                    ? CircularProgressIndicator()
                    : Container(
                        child: _buildSubmitButton(),
                        width: 200,
                      ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
