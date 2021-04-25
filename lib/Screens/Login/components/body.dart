import 'package:flutter/material.dart';
import 'package:finto_spoti/Screens/Login/components/background.dart';
import 'package:finto_spoti/Screens/Signup/signup_screen.dart';
import 'package:finto_spoti/components/already_have_an_account_acheck.dart';
import 'package:finto_spoti/components/rounded_button.dart';
import 'package:finto_spoti/components/rounded_input_field.dart';
import 'package:finto_spoti/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class Body extends StatefulWidget {
  Body({
    Key key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isHidden = true,
      wantsToSavePassword = false,
      isEmailValid = true,
      emailValid = true,
      isHidden_1 = false,
      isPassword1Valid = true,
      requestStarted = false;

  String email = "", psw_1 = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "LOGIN",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/login_2.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
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
                emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                email = value;
              },
            ),
            RoundedPasswordField(
              hidden: isHidden_1,
              border: isPassword1Valid
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 50.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
              onChanged: (value) {
                psw_1 = value;
                if (psw_1.length < 8) {
                  isPassword1Valid = false;
                  return;
                }
              },
              press: () {
                isHidden_1 = !isHidden_1;
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
              textColor: Colors.white,
              text: "LOGIN",
              isLoading: requestStarted,
              press: () {},
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
