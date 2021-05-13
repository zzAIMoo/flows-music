import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'components/search_screen.dart';
import 'package:finto_spoti/components/rounded_button.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
//import 'package:image/image.dart' as IMG;

void main() {
  runApp(MyApp());
}

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

  bool swipeLeft = false,
      swipeRight = false,
      still = true,
      requestStarted = false;
  String accessToken = "";
  @override
  void initState() {
    super.initState();
    // ignore: invalid_use_of_visible_for_testing_member
    getSharedPrefs();
  }

  List<Widget> funzioneCarina(BuildContext context) {
    // ignore: unused_local_variable
    CardController controller;
    return <Widget>[
      Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: new TinderSwapCard(
              swipeUp: false,
              swipeDown: false,
              orientation: AmassOrientation.BOTTOM,
              totalNum: songImages.length,
              stackNum: 3,
              swipeEdge: 3.0,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.width * 0.9,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.width * 0.8,
              /*cardBuilder: (context, index) => Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(80.0),
                  child: Image.network('${songImages[index]}',
                      width: 150.0, height: 100.0),
                ),
                elevation: 20,
              ),*/
              cardBuilder: (context, index) => Card(
                  child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                      width: 250.0,
                      height: 250.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image:
                                  new NetworkImage('${songImages[index]}')))),
                ],
              )),
              cardController: controller = CardController(),
              swipeUpdateCallback:
                  (DragUpdateDetails details, Alignment align) {
                /// Get swiping card's alignment
                if (align.x < -3) {
                  setState(() {
                    still = false;
                    swipeLeft = true;
                    swipeRight = false;
                  });
                  //Card is LEFT swiping
                } else if (align.x > 3) {
                  setState(() {
                    still = false;
                    swipeLeft = false;
                    swipeRight = true;
                  });
                  //Card is RIGHT swiping
                } else if (align.x > -3 && align.x < 3) {
                  setState(() {
                    still = true;
                    swipeLeft = false;
                    swipeRight = false;
                  });
                }
              },
              swipeCompleteCallback:
                  (CardSwipeOrientation orientation, int index) {
                still = true;
                swipeLeft = false;
                swipeRight = false;
                print(orientation);
              },
            ),
          ),
          still
              ? Container()
              : swipeRight
                  ? Icon(Icons.check)
                  : swipeLeft
                      ? Icon(Icons.close)
                      : Container(),
        ],
      ),
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

  List<String> songImages = [
    "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
    "https://images.unsplash.com/photo-1612979857678-0ce10e5b3439?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=1350&q=80",
    "https://images.unsplash.com/photo-1613066839141-4489f60e0389?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80",
    "https://images.unsplash.com/photo-1613066839141-4489f60e0389?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80",
    "https://images.unsplash.com/photo-1613098169745-015562f6f27a?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80",
    "https://images.unsplash.com/photo-1612979857678-0ce10e5b3439?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=1350&q=80",
    "https://images.unsplash.com/photo-1613066839141-4489f60e0389?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80",
    "https://images.unsplash.com/photo-1613066839141-4489f60e0389?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80"
  ];
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
      appBar: AppBar(
        title: const Text('Flows'),
      ),
      body: Center(
        child: funzioneCarina(context).elementAt(_selectedIndex),
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
