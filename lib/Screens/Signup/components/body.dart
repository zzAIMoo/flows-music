import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:finto_spoti/Screens/Login/login_screen.dart';
import 'package:finto_spoti/Screens/Signup/components/background.dart';
import 'package:finto_spoti/Screens/Signup/components/or_divider.dart';
import 'package:finto_spoti/Screens/Signup/components/social_icon.dart';
import 'package:finto_spoti/components/already_have_an_account_acheck.dart';
import 'package:finto_spoti/components/rounded_button.dart';
import 'package:finto_spoti/components/rounded_input_field.dart';
import 'package:finto_spoti/components/rounded_password_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class Body extends StatelessWidget {
  bool isHidden = true;
  bool isHidden2 = true;
  String psw_1 = "", psw_2 = "";
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
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            RoundedInputField(
              hintText: "Your Email",
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              onChanged: (value) {
                psw_1 = value;
              },
              hidden: isHidden,
              press: () {
                print(isHidden);
                isHidden = !isHidden;
                (context as Element).markNeedsBuild();
              },
            ),
            RoundedPasswordField(
              onChanged: (value) {
                psw_2 = value;
              },
              hidden: isHidden2,
              press: () {
                print(isHidden2);
                isHidden2 = !isHidden2;
                (context as Element).markNeedsBuild();
              },
            ),
            RoundedButton(
              text: "SIGNUP",
              textColor: Colors.white,
              press: () {
                if (psw_1 != psw_2) {
                  Fluttertoast.showToast(
                      msg: "Le password non coincidono",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 24.0);
                } else {}
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/twitter.svg",
                  press: () {},
                ),
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

  Future<http.Response> registerAction() {
    return http.post(
      Uri.https('jsonplaceholder.typicode.com', 'albums'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': "ciao",
      }),
    );
  }
}
