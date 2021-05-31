import 'package:flutter/material.dart';
import 'package:flows/Screens/Login/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        buttonColor: Color(0xFF6F35A5),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Color(0xFF6F35A5),
        accentColor: Color(0xFF6F35A5),
        primaryColor: Color(0xFF6F35A5),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(),
    );
  }
}
