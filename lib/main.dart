import 'package:flutter/material.dart';
import 'package:flows/Screens/Login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flows/Screens/Main/main_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool requestStarted = false;
  String refreshToken = "";

  @override
  void initState() {
    super.initState();
    //getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Color(0xFF6F35A5),
        ),
        highlightColor: Color(0xFF6F35A5),
        focusColor: Color(0xFF6F35A5),
        primaryColor: Color(0xFF6F35A5),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(),
    );
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences.getInstance().then((SharedPreferences prefs) async {
      if (prefs.containsKey("refresh_token")) {
        refreshToken = prefs.getString("refresh_token");
        requestStarted = true;
        var url =
            Uri.parse('https://api.flowsmusic.it/registration/signin.php');
        var response =
            await http.post(url, body: {'refresh_token': refreshToken});
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (response.statusCode == 200) {
          var responseParsed = convert.jsonDecode(response.body);
          if (responseParsed["response_type"] == "loggedin_correctly") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token',
                responseParsed["response_body"]["access_token"]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        }
      }
    });
  }
}
