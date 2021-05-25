import 'package:flows/Screens/Main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flows/Screens/Login/components/background.dart';
import 'package:flows/Screens/Signup/signup_screen.dart';
import 'package:flows/components/already_have_an_account_acheck.dart';
import 'package:flows/components/rounded_button.dart';
import 'package:flows/components/rounded_input_field.dart';
import 'package:flows/components/rounded_password_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
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
  bool isHidden = true, wantsToSavePassword = false, requestStarted = false;
  String email = "", psw = "", refreshToken = "";

  Future<Null> getSharedPrefs() async {
    SharedPreferences.getInstance().then((SharedPreferences prefs) async {
      if (prefs.containsKey("refresh_token")) {
        refreshToken = prefs.getString("refresh_token");
        print(refreshToken);
        requestStarted = true;
        var url = Uri.parse('https://sechisimone.altervista.org/flows/API/registration/signin.php');
        var response = await http.post(
          url,
          body: {'refresh_token': refreshToken},
        );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (response.statusCode == 200) {
          var responseParsed = convert.jsonDecode(response.body);
          if (responseParsed["response_type"] == "loggedin_correctly") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', responseParsed["response_body"]["access_token"]);
            if (wantsToSavePassword) {
              await prefs.setString('refresh_token', responseParsed["response_body"]["refresh_token"]);
            }
            requestStarted = false;
            setState(() {});
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } else if (responseParsed["response_type"] == "loggedin_correctly") {
            showToast("There has been an error loggin in, please retry");
            requestStarted = false;
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

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
              border: InputBorder.none,
              color: Color(0xFF6F35A5),
              hintText: "Your Email",
              onChanged: (value) {
                email = value;
              },
            ),
            RoundedPasswordField(
              hidden: isHidden,
              border: InputBorder.none,
              onChanged: (value) {
                psw = value;
              },
              press: () {
                isHidden = !isHidden;
                setState(() {});
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Keep me logged in!"),
                Checkbox(
                  fillColor: MaterialStateColor.resolveWith((states) => Color(0xFF6F35A5)),
                  checkColor: Colors.white,
                  value: wantsToSavePassword,
                  onChanged: (newValue) {
                    wantsToSavePassword = newValue;
                    setState(() {});
                  },
                ),
              ],
            ),
            RoundedButton(
              text: "LOGIN",
              textColor: Colors.white,
              isLoading: requestStarted,
              press: () async {
                requestStarted = true;
                setState(() {});
                var url = Uri.parse('https://sechisimone.altervista.org/flows/API/registration/signin.php');
                var response = await http.post(url, body: {'email': email, 'password': psw});
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');
                if (response.statusCode == 200) {
                  var responseParsed = convert.jsonDecode(response.body);
                  if (responseParsed["response_type"] == "error_logging_in") {
                    showToast("C'è stato un errore nel login, si è pregati di riprovare con altri dati");
                    requestStarted = false;
                    setState(() {});
                    return;
                  } else if (responseParsed["response_type"] == "email_error") {
                    showToast("Ci sono problemi con i server, si è pregati di riprovare più tardi");
                    requestStarted = false;
                    setState(() {});
                    return;
                  } else if (responseParsed["response_type"] == "loggedin_correctly") {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('access_token', responseParsed["response_body"]["access_token"]);
                    if (wantsToSavePassword) {
                      if (prefs.containsKey("refresh_token")) {
                        prefs.remove("refresh_token");
                      }
                      await prefs.setString('refresh_token', responseParsed["response_body"]["refresh_token"]);
                    }
                    print(responseParsed["response_body"]["access_token"]);
                    requestStarted = false;
                    setState(() {});
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  }
                }
              },
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
