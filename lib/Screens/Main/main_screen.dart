import 'package:flutter/material.dart';
import 'components/search_screen.dart';
import 'components/card_screen.dart';
import 'components/library_screen.dart';
import 'package:flows/Screens/Settings/settings_screen.dart';

class MainScreenPage extends StatefulWidget {
  @override
  _MainScreenPageState createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<MainScreenPage> {
  List<String> urls = [
    'https://sechisimone.altervista.org/flows/songs/RADICAL__MINACCIA.mp3',
    "http://135.125.44.178/songs/a3b44c0172b8c62e9fc621ecbb72bacf.mp3",
    "http://135.125.44.178/songs/77f793ad27389e97f5b32e2103b8da7e.mp3"
  ];

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        ),
                      ),
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
          /*Miniplayer(
            minHeight: 70,
            backgroundColor: Colors.transparent,
            maxHeight: 70,
            builder: (height, percentage) {
              return Center(
                child: ValueListenableBuilder<ButtonState>(
                  valueListenable: _cardManager.buttonNotifier,
                  builder: (_, value, __) {
                    switch (value) {
                      case ButtonState.loading:
                        return Container(
                          margin: EdgeInsets.all(8.0),
                          width: 32.0,
                          height: 32.0,
                          child: CircularProgressIndicator(),
                        );
                      case ButtonState.paused:
                        return IconButton(
                          icon: Icon(Icons.play_arrow),
                          iconSize: 32.0,
                          onPressed: _cardManager.play,
                        );
                      case ButtonState.playing:
                        return IconButton(
                          icon: Icon(Icons.pause),
                          iconSize: 32.0,
                          onPressed: _cardManager.pause,
                        );
                      default:
                        return Container();
                    }
                  },
                ),
              );
            },
          ),*/
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Suggestions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF6F35A5),
        onTap: _onItemTapped,
      ),
    );
  }
}
