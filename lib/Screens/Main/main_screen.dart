import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'components/search_screen.dart';
//import 'package:image/image.dart' as IMG;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'homeScreen',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(title: 'Home'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool swipeLeft = false, swipeRight = false, still = true;
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
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              leading: Icon(Icons.album),
              title: Text('The Enchanted Nightingale'),
              subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('BUY TICKETS'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('LISTEN'),
                  onPressed: () {/* ... */},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    ];
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
