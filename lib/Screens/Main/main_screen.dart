import 'package:flutter/material.dart';
import 'components/search_screen.dart';
import 'components/card_screen.dart';
import 'components/library_screen.dart';
import 'package:flows/Screens/Settings/settings_screen.dart';
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
  @override
  void initState() {
    super.initState();
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
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsScreen()),
                              );
                            }),
                      ],
                    ),
                  ],
                  title: Text('Suggestions'),
                )
              : _selectedIndex == 2
                  ? AppBar(
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                icon: Icon(Icons.settings),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SettingsScreen()),
                                  );
                                }),
                          ],
                        ),
                      ],
                      title: Text('Library'),
                    )
                  : null,
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
