import 'package:flows/Screens/Login/login_screen.dart';
import 'package:flows/Screens/Main/components/playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flows/components/rounded_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
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
    print("access-token:" + accessToken);
    refreshToken = prefs.getString("refresh_token");
  }

  void doStuff() async {
    await getSharedPrefs();
    await receivePlaylists();
  }

  ScrollController _scrollController = new ScrollController();
  bool requestStarted = false;
  String accessToken = "", refreshToken = "";
  int playlistsNumber = 0;
  List<Widget> playlists = [];

  @override
  void initState() {
    super.initState();
    doStuff();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*
          RoundedButton(
            text: "CREATE FAKE PLAYLIST",
            textColor: Colors.white,
            isLoading: requestStarted,
            press: () {
              createPlaylist(generateRandomString(5));
            },
          ),*/
          Container(
            child: Expanded(
              child: ListView.builder(
                itemCount: playlistsNumber,
                itemBuilder: (_, int index) => playlists[index],
                controller: _scrollController,
              ),
            ),
          ),
        ],
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

  Widget shimmerItems(index) {
    if (index < 6) {
      return Card(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 7.0),
          padding: EdgeInsets.all(12.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.white,
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), //or 15.0
                  child: Container(
                    height: 70.0,
                    width: 70.0,
                    color: Color(0xffFF0E58),
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: 20.0)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), //or 15.0
                  child: Container(
                    height: 10.0,
                    width: 80.0,
                    color: Color(0xffFF0E58),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  receivePlaylists() async {
    requestStarted = true;
    setState(() {});
    var url = Uri.parse('https://api.flowsmusic.it/read/get_user_playlists.php');
    var response = await http.post(url, body: {
      'access_token': accessToken,
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      var responseParsed = convert.jsonDecode(response.body);
      print(responseParsed);
      if (responseParsed["response_type"] == "received_correctly") {
        var tmp = responseParsed["response_body"]["playlists"];
        playlistsNumber = tmp.length;
        tmp.forEach((element) {
          playlists.add(
            Card(
              child: InkWell(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("playlist_name", element['playlist_name']).then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistScreen(),
                      ),
                    );
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 7.0),
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: <Widget>[
                      /*Image.network(
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                      ),*/
                      Padding(padding: EdgeInsets.only(right: 20.0)),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              element['playlist_name'],
                              softWrap: true,
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Padding(padding: EdgeInsets.only(bottom: 1.5)),
                            Text(
                              element['playlist_description'],
                              softWrap: true,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
          print(element);
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access_token', responseParsed["response_body"]["access_token"].toString());
        requestStarted = false;
        setState(() {});
        return;
      } else if (responseParsed["response_type"] == "error_in_retrieving") {
        print(responseParsed);
        showToast("C'è stato un errore nella ricezione delle tue playlists");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access_token', responseParsed["response_body"]["access_token"].toString());
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
              receivePlaylists();
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

  createPlaylist(playlistName) async {
    requestStarted = true;
    setState(() {});
    var url = Uri.parse('https://api.flowsmusic.it/create/add_playlist.php');
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
        await prefs.setString('access_token', responseParsed["response_body"]["access_token"].toString());
        requestStarted = false;
        setState(() {});
        return;
      } else if (responseParsed["response_type"] == "error_in_adding") {
        showToast("C'è stato un errore nella creazione della playlist");
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
          var responseParsed = convert.jsonDecode(response.body);
          if (responseParsed["response_type"] == "access_token_created_correctly") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token', responseParsed["response_body"]["access_token"]).then((value) {
              createPlaylist(playlistName);
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

  String generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }
}
