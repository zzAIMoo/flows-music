import 'package:flutter/material.dart';
import 'package:flows/components/rounded_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:math';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("access_token");
  }

  bool requestStarted = false;
  String accessToken = "";

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedButton(
          text: "CREATE FAKE PLAYLIST",
          textColor: Colors.white,
          isLoading: requestStarted,
          press: () async {
            requestStarted = true;
            setState(() {});
            String randomName = generateRandomString(5);
            var url = Uri.parse(
                'https://sechisimone.altervista.org/flows/API/create/add_playlist.php');
            print(randomName);
            print(accessToken);
            var response = await http.post(url, body: {
              'name': randomName,
              'description': "descrizione",
              'access_token': accessToken,
            });
            print('Response status: ${response.statusCode}');
            print('Response body: ${response.body}');
            if (response.statusCode == 200) {
              var responseParsed = convert.jsonDecode(response.body);
              print(responseParsed["response_type"]);
              if (responseParsed["response_type"] == "playlist_added") {
                showToast(
                    "Playlist creata correttamente con il nome " + randomName);
                requestStarted = false;
                (context as Element).markNeedsBuild();
                return;
              } else if (responseParsed["response_type"] == "error_in_adding") {
                showToast("C'è stato un errore nella creazione della playlist");
                requestStarted = false;
                (context as Element).markNeedsBuild();
                return;
              }
            }
          },
        ),
      ],
    );
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
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
