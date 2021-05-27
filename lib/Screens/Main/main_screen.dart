import 'package:flutter/material.dart';
import 'components/search_screen.dart';
import 'components/card_screen.dart';
import 'components/library_screen.dart';
import 'components/card_manager.dart';
import 'package:flows/Screens/Settings/settings_screen.dart';
import 'package:miniplayer/miniplayer.dart';
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
  CardManager _cardManager;
  List<String> urls = [
    'https://sechisimone.altervista.org/flows/songs/RADICAL__MINACCIA.mp3',
    "http://135.125.44.178/songs/a3b44c0172b8c62e9fc621ecbb72bacf.mp3",
    "http://135.125.44.178/songs/77f793ad27389e97f5b32e2103b8da7e.mp3"
  ];

  @override
  void initState() {
    super.initState();
    _cardManager = new CardManager(urls[0]);
  }

  List<Widget> buildPage(BuildContext context) {
    return <Widget>[
      CardScreen(),
      SearchScreen(),
      LibraryScreen(),
    ];
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1
          ? null
          : _selectedIndex == 0
              ? AppBar(
                  backgroundColor: Color(0xFF6F35A5),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SettingsScreen()),
                              );
                            }),
                      ],
                    ),
                  ],
                  title: Text('Suggestions'),
                )
              : _selectedIndex == 2
                  ? AppBar(
                      backgroundColor: Color(0xFF6F35A5),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                icon: Icon(Icons.settings),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                                  );
                                }),
                          ],
                        ),
                      ],
                      title: Text('Library'),
                    )
                  : null,
      body: Stack(
        children: [
          Center(
            child: buildPage(context).elementAt(_selectedIndex),
          ),
          Miniplayer(
            minHeight: 70,
            maxHeight: MediaQuery.of(context).size.height - 137,
            builder: (height, percentage) {
              return Center(
                child: Text('$height, $percentage'),
              );
            },
          ),
        ],
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
        selectedItemColor: Color(0xFF6F35A5),
        onTap: _onItemTapped,
      ),
    );
  }
}
