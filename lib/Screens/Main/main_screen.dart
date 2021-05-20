import 'package:flutter/material.dart';
import 'components/search_screen.dart';
import 'components/card_screen.dart';
import 'package:finto_spoti/components/rounded_button.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
//import 'package:image/image.dart' as IMG;

void main() {}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'homeScreen',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MainScreenPage(title: 'Home'),
    );
  }
}

class MainScreenPage extends StatefulWidget {
  MainScreenPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainScreenPageState createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<MainScreenPage> {
  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("access_token");
  }

  bool requestStarted = false;
  String accessToken = "";
  @override
  void initState() {
    super.initState();
    // ignore: invalid_use_of_visible_for_testing_member
    getSharedPrefs();
  }

  List<Widget> buildPage(BuildContext context) {
    // ignore: unused_local_variable
    return <Widget>[
      CardScreen(),
      SearchScreen(),
      Column(
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
                    showToast("Playlist creata correttamente con il nome " +
                        randomName);
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    return;
                  } else if (responseParsed["response_type"] ==
                      "error_in_adding") {
                    showToast(
                        "C'è stato un errore nella creazione della playlist");
                    requestStarted = false;
                    (context as Element).markNeedsBuild();
                    return;
                  }
                }
              }),
        ],
      )
    ];
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

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /*IMG.Image transformImage(IMG.Image image) {
    IMG.fill(image, IMG.getColor(0, 0, 255));
    return image;
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1
          ? null
          : AppBar(
              title: const Text('Flows'),
            ),
      body: Center(
        child: buildPage(context).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Ricerca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded),
            label: 'Libreria',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
