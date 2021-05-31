import 'package:flutter/material.dart';
import 'package:flows/Screens/Login/login_screen.dart';
import 'package:flows/Screens/Signup/components/background.dart';
import 'package:flows/Screens/Signup/components/or_divider.dart';
import 'package:flows/Screens/Signup/components/social_icon.dart';
import 'package:flows/components/already_have_an_account_acheck.dart';
import 'package:flows/components/rounded_button.dart';
import 'package:flows/components/rounded_input_field.dart';
import 'package:flows/components/rounded_password_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
// ignore: unused_import
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isHidden = true, requestStarted = false, isUsernameValid = true, isEmailValid = true, isPasswordValid = true;

  String username = "", mail = "", psw = "", email = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              inputType: TextInputType.text,
              border: isUsernameValid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              color: Color(0xFF6F35A5),
              hintText: "Your Username (no spaces)",
              onChanged: (value) {
                username = value;
              },
            ),
            RoundedInputField(
              icon: Icons.email_rounded,
              inputType: TextInputType.emailAddress,
              border: isEmailValid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              color: Color(0xFF6F35A5),
              hintText: "Your Email",
              onChanged: (value) {
                isEmailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                email = value;
              },
            ),
            RoundedPasswordField(
              hidden: isHidden,
              border: isPasswordValid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              onChanged: (value) {
                psw = value;
                if (value.length < 8) {
                  setState(() {
                    isPasswordValid = false;
                  });
                  return;
                }
              },
              press: () {
                isHidden = !isHidden;
                setState(() {});
              },
            ),
            RoundedButton(
              text: "SIGNUP",
              textColor: Colors.white,
              isLoading: requestStarted,
              press: () async {
                if (username.contains(" ")) {
                  showToast("The username can't contain spaces");
                  isUsernameValid = false;
                } else if (psw.length < 9) {
                  showToast("The password must be longer then 9 characters");
                  isPasswordValid = false;
                }
                if (username == "" || email == "" || psw == "") {
                  showToast("One of the fields is empty");
                  return;
                } else if (!isEmailValid) {
                  isEmailValid = false;
                  showToast("Email format is invalid");
                  setState(() {});
                  return;
                }
                requestStarted = true;
                setState(() {});
                var url = Uri.parse('https://api.flowsmusic.it/registration/signup.php');
                var response = await http.post(url, body: {'email': email, 'username': username, 'password': psw});
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');
                if (response.statusCode == 200) {
                  var responseParsed = convert.jsonDecode(response.body);
                  print(responseParsed["response_type"]);
                  if (responseParsed["response_type"] == "already_registered") {
                    showToast("Mail/Username are already used in another account");
                    requestStarted = false;
                    setState(() {});
                    return;
                  } else if (responseParsed["response_type"] == "email_error") {
                    showToast("There are problems with the servers, please retry later");
                    requestStarted = false;
                    setState(() {});
                    return;
                  } else if (responseParsed["response_type"] == "email_sent") {
                    requestStarted = false;
                    setState(() {});
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                      (Route route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Email di verifica inviata!'),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                }
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (Route route) => false,
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/google-plus.svg",
                  press: () {},
                ),
              ],
            )
          ],
        ),
      ),
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
