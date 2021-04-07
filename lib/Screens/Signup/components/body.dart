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
import 'package:finto_spoti/Screens/EmailConfirm/email_confirm_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
// ignore: unused_import
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class Body extends StatelessWidget {
  bool isHidden_1 = true,
      isHidden_2 = true,
      emailValid = true,
      wantsToSavePassword = false,
      requestStarted = false;
  bool isUsernameValid = true,
      isEmailValid = true,
      isPassword1Valid = true,
      isPassword2Valid = true;
  String username = "", mail = "", psw_1 = "", psw_2 = "", email = "";

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
            /*SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),*/
            RoundedInputField(
              border: isUsernameValid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              color: Color(0xFF6F35A5),
              hintText: "Your Username",
              onChanged: (value) {
                username = value;
              },
            ),
            RoundedInputField(
              border: isEmailValid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              color: Color(0xFF6F35A5),
              hintText: "Your Email",
              onChanged: (value) {
                emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                email = value;
              },
            ),
            RoundedPasswordField(
              hidden: isHidden_1,
              border: isPassword2Valid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              onChanged: (value) {
                psw_1 = value;
                if (value.length < 8) {
                  isPassword1Valid = false;
                  return;
                }
              },
              press: () {
                isHidden_1 = !isHidden_1;
                (context as Element).markNeedsBuild();
              },
            ),
            RoundedPasswordField(
              hidden: isHidden_2,
              border: isPassword2Valid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              onChanged: (value) {
                psw_2 = value;
                if (value.length < 8) {
                  isPassword2Valid = false;
                  return;
                }
              },
              press: () {
                isHidden_2 = !isHidden_2;
                (context as Element).markNeedsBuild();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Salva Credenziali"),
                Checkbox(
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => Color(0xFF6F35A5)),
                  checkColor: Colors.white,
                  value: wantsToSavePassword,
                  onChanged: (newValue) {
                    wantsToSavePassword = newValue;
                    (context as Element).markNeedsBuild();
                  },
                ),
              ],
            ),
            RoundedButton(
              text: "SIGNUP",
              textColor: Colors.white,
              isLoading: requestStarted,
              press: () async {
                if (psw_1.length < 8 || psw_2.length < 8) {
                  Fluttertoast.showToast(
                      msg: "La password deve essere lunga almeno 8 caratteri",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 24.0);
                  if (psw_1.length < 8) isPassword1Valid = false;

                  if (psw_2.length < 8) isPassword2Valid = false;
                  (context as Element).markNeedsBuild();
                  return;
                }
                if (username == "" ||
                    email == "" ||
                    psw_1 == "" ||
                    psw_2 == "") {
                  Fluttertoast.showToast(
                      msg: "Uno dei campi è vuoto",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 24.0);
                  return;
                }
                if (psw_1 != psw_2) {
                  Fluttertoast.showToast(
                      msg: "Le password non coincidono",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 24.0);
                  return;
                } else if (emailValid == false) {
                  isEmailValid = false;
                  Fluttertoast.showToast(
                      msg: "Formato email non valido",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 24.0);
                  (context as Element).markNeedsBuild();
                  return;
                }
                requestStarted = true;
                (context as Element).markNeedsBuild();
                var url = Uri.parse(
                    'http://192.168.178.86/Flows_Progetto_Esame/API/registration/signup.php');
                var response = await http.post(url, body: {
                  'email': email,
                  'username': username,
                  'password': psw_1
                });
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');
                if (response.statusCode == 200) {
                  var responseParsed = convert.jsonDecode(response.body);
                  print(responseParsed["response_type"]);
                  if (responseParsed["response_type"] == "already_registered") {
                    Fluttertoast.showToast(
                        msg: "Mail/Username già utilizzati in un altro account",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 24.0);
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    return;
                  } else if (responseParsed["response_type"] == "email_error") {
                    Fluttertoast.showToast(
                        msg:
                            "Ci sono problemi con i server, si è pregati di riprovare più tardi",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 24.0);
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    return;
                  } else if (responseParsed["response_type"] == "email_sent") {
                    if (wantsToSavePassword) {
                      // ignore: invalid_use_of_visible_for_testing_member
                      SharedPreferences.setMockInitialValues({});
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('email', email);
                      prefs.setString('pass',
                          sha256.convert(utf8.encode(psw_1)).toString());
                    }
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EmailConfirm()),
                    );
                    return;
                  }
                }
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
}
