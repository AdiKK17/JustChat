import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './models/user.dart';
import './models/chatroom.dart';
import './models/message.dart';

import 'providers/auth_provider.dart';
import 'pages/home_page.dart';
import './pages/auth_page.dart';

void main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(MyApp());
}

Future<void> initHive() async {
  Hive.registerAdapter<User>(UserAdapter());
  Hive.registerAdapter<ChatRoom>(ChatRoomAdapter());
  Hive.registerAdapter<Message>(MessageAdapter());
  await Hive.openBox<User>("user");
  await Hive.openBox<ChatRoom>("chatroom");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    new Timer(Duration(milliseconds: 100), checkLogin);
  }

  checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString("isLoggedIn");
    if (value == "yes") {
      await Provider.of<AuthProvider>(context, listen: false).setVariables();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Text(
          "Hello",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
