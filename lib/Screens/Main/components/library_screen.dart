import 'package:flows/Screens/Login/login_screen.dart';
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
    refreshToken = prefs.getString("refresh_token");
  }

  bool requestStarted = false;
  String accessToken = "", refreshToken = "";

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
          press: () {
            createPlaylist(generateRandomString(5));
          },
        ),
      ],
    );
  }

  createPlaylist(playlistName) async {
    requestStarted = true;
    setState(() {});
    var url = Uri.parse(
        'https://sechisimone.altervista.org/flows/API/create/add_playlist.php');
    var response = await http.post(url, body: {
      'name': playlistName,
      'description': "descrizione",
      'access_token': accessToken,
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var responseParsed = convert.jsonDecode(response.body);
      if (responseParsed["response_type"] == "playlist_added") {
        showToast("Playlist creata correttamente con il nome " + playlistName);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access_token',
            responseParsed["response_body"]["access_token"].toString());
        requestStarted = false;
        setState(() {});
        return;
      } else if (responseParsed["response_type"] == "error_in_adding") {
        showToast("C'è stato un errore nella creazione della playlist");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access_token',
            responseParsed["response_body"]["access_token"].toString());
        requestStarted = false;
        setState(() {});
        return;
      } else if (responseParsed["response_type"] == "access_token_expired") {
        var url = Uri.parse(
            'https://sechisimone.altervista.org/flows/API/OAuth/get_access_token.php');
        var response = await http.post(url, body: {
          'refresh_token': refreshToken,
        });
        if (response.statusCode == 200) {
          var responseParsed = convert.jsonDecode(response.body);
          if (responseParsed["response_type"] ==
              "access_token_created_correctly") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token',
                responseParsed["response_body"]["access_token"]);
            createPlaylist(playlistName);
          } else if (responseParsed["response_type"] ==
              "refresh_token_expired") {
            showToast("Token Expired, logging out of the account");
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            requestStarted = false;
            setState(() {});
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          }
        }
      }
    }
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
