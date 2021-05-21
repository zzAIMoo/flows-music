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
  bool isHidden = true,
      requestStarted = false,
      isUsernameValid = true,
      isEmailValid = true,
      isPasswordValid = true;

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
            /*SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),*/

            //TODO: https://api.flutter.dev/flutter/material/TextFormField-class.html

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
                isEmailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
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
                  showToast("Lo username non può contenere spazi");
                  isUsernameValid = false;
                } else if (psw.length < 8 /*|| psw_2.length < 8*/) {
                  showToast("La password deve essere lunga almeno 8 caratteri");
                  isPasswordValid = false;

                  /*if (psw_2.length < 8) isPassword2Valid = false;
                  (context as Element).markNeedsBuild();
                  return;*/
                }
                if (username == "" ||
                        email == "" ||
                        psw == "" /*||
                    psw_2 == ""*/
                    ) {
                  showToast("Uno dei campi è vuoto");
                  return;
                }
                //probabilmente non lo userò più
                /*if (psw_1 != psw_2) {
                  Fluttertoast.showToast(
                      msg: "Le password non coincidono",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 24.0);
                  return;
                }*/
                else if (!isEmailValid) {
                  isEmailValid = false;
                  showToast("Formato email non valido");
                  (context as Element).markNeedsBuild();
                  return;
                }
                requestStarted = true;
                setState(() {});
                var url = Uri.parse(
                    'https://sechisimone.altervista.org/flows/API/registration/signup.php');
                var response = await http.post(url, body: {
                  'email': email,
                  'username': username,
                  'password': psw
                });
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');
                if (response.statusCode == 200) {
                  var responseParsed = convert.jsonDecode(response.body);
                  print(responseParsed["response_type"]);
                  if (responseParsed["response_type"] == "already_registered") {
                    showToast(
                        "Mail/Username già utilizzati in un altro account");
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    return;
                  } else if (responseParsed["response_type"] == "email_error") {
                    showToast(
                        "Ci sono problemi con i server, si è pregati di riprovare più tardi");
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    return;
                  } else if (responseParsed["response_type"] == "email_sent") {
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Email di verifica inviata!'),
                      behavior: SnackBarBehavior.floating,
                      /*action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {},
                      ),*/
                    ));
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
