import 'package:flows/Screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flows/components/rounded_button.dart';
//import 'package:flows/components/rounded_input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// ignore: must_be_immutable
class Body extends StatefulWidget {
  Body({
    Key key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool requestStarted = false;
  String accessToken = "", refreshToken = "", username = "";
  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("access_token");
    refreshToken = prefs.getString("refresh_token");
  }

  getUserInfo() async {
    requestStarted = true;
    setState(() {});
    var url = Uri.parse('https://api.flowsmusic.it/read/get_user_info.php');
    var response = await http.post(url, body: {
      'access_token': accessToken,
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var responseParsed = convert.jsonDecode(response.body);
      if (responseParsed["response_type"] == "received_correctly") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', responseParsed["response_body"]["access_token"].toString());
        requestStarted = false;
        setState(() {});
        return;
      } else if (responseParsed["response_type"] == "error_in_retrieving") {
        showToast("C'è stato un errore nella ricezione dei tuoi dati");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', responseParsed["response_body"]["access_token"].toString());
        requestStarted = false;
        setState(() {});
        return;
      } else if (responseParsed["response_type"] == "access_token_expired") {
        var url = Uri.parse('https://api.flowsmusic.it/OAuth/get_access_token.php');
        var response = await http.post(url, body: {
          'refresh_token': refreshToken,
        });
        if (response.statusCode == 200) {
          print(response.body);
          var responseParsed = convert.jsonDecode(response.body);
          if (responseParsed["response_type"] == "access_token_created_correctly") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token', responseParsed["response_body"]["access_token"]).then((value) {
              getUserInfo();
            });
          } else if (responseParsed["response_type"] == "refresh_token_expired") {
            showToast("Token Expired, logging out of the account");
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            requestStarted = false;
            setState(() {});
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
              (Route route) => false,
            );
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    //getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 25.0),
          width: 150.0,
          height: 150.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
              fit: BoxFit.fill,
              image: Image.asset("assets/images/default_user_img.png").image,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                "Username",
                style: TextStyle(fontSize: 22),
              ),
              margin: EdgeInsets.only(top: 15.0, left: 70.0),
            ),
            Container(
              child: MaterialButton(
                onPressed: () {},
                color: Color(0xFF6F35A5),
                textColor: Colors.white,
                child: Icon(
                  Icons.edit,
                  size: 16,
                ),
                shape: CircleBorder(),
              ),
              margin: EdgeInsets.only(top: 15.0),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                "Password: *****",
                style: TextStyle(fontSize: 22),
              ),
              margin: EdgeInsets.only(top: 15.0, left: 70.0),
            ),
            Container(
              child: MaterialButton(
                onPressed: () {},
                color: Color(0xFF6F35A5),
                textColor: Colors.white,
                child: Icon(
                  Icons.edit,
                  size: 16,
                ),
                shape: CircleBorder(),
              ),
              margin: EdgeInsets.only(top: 15.0),
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: RoundedButton(
              text: "LOGOUT",
              textColor: Colors.white,
              isLoading: requestStarted,
              press: () {
                logout();
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 50),
        ),
      ],
    );
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    requestStarted = false;
    prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
      (Route route) => false,
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 24.0);
  }
}
