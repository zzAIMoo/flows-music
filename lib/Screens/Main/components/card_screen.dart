import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:finto_spoti/components/rounded_button.dart';

class CardScreen extends StatefulWidget {
  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  int currIndex = 0;
  bool swipeLeft = false, swipeRight = false, still = true;
  double gradValue = 1.0;
  CardController controller;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return currIndex != songImages.length
        ? Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: new TinderSwapCard(
                  swipeUp: false,
                  swipeDown: false,
                  orientation: AmassOrientation.BOTTOM,
                  totalNum: songImages.length,
                  stackNum: 3,
                  swipeEdge: 2.5,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.width * 0.9,
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  minHeight: MediaQuery.of(context).size.width * 0.8,
                  cardBuilder: (context, index) => !swipeLeft && !swipeRight ||
                          index != currIndex
                      ? Card(
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
                                    image: new NetworkImage(
                                        '${songImages[index]}'),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : swipeLeft
                          ? ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  stops: [0.0, gradValue / 2, gradValue],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight,
                                  colors: <Color>[
                                    Colors.red[800],
                                    Colors.red,
                                    Colors.white,
                                  ],
                                  tileMode: TileMode.clamp,
                                ).createShader(bounds);
                              },
                              child: Card(
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
                                          image: new NetworkImage(
                                              '${songImages[index]}'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  stops: [0.0, gradValue / 2, gradValue],
                                  begin: FractionalOffset.topRight,
                                  end: FractionalOffset.bottomLeft,
                                  colors: <Color>[
                                    Colors.green[800],
                                    Colors.green,
                                    Colors.white,
                                  ],
                                  tileMode: TileMode.clamp,
                                ).createShader(bounds);
                              },
                              child: Card(
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
                                          image: new NetworkImage(
                                              '${songImages[index]}'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                  cardController: controller = CardController(),
                  swipeUpdateCallback:
                      (DragUpdateDetails details, Alignment align) {
                    /// Get swiping card's alignment
                    gradValue = (align.x / 10).abs() + 0.15;
                    if (align.x < -1) {
                      setState(() {
                        still = false;
                        swipeLeft = true;
                        swipeRight = false;
                      });
                      //Card is LEFT swiping
                    } else if (align.x > 1) {
                      setState(() {
                        still = false;
                        swipeLeft = false;
                        swipeRight = true;
                      });
                      //Card is RIGHT swiping
                    } else if (align.x > -1 && align.x < 1) {
                      setState(() {
                        still = true;
                        swipeLeft = false;
                        swipeRight = false;
                      });
                    }
                  },
                  swipeCompleteCallback:
                      (CardSwipeOrientation orientation, int index) {
                    if (orientation == CardSwipeOrientation.RIGHT ||
                        orientation == CardSwipeOrientation.LEFT) {
                      currIndex++;
                    }
                    still = true;
                    swipeLeft = false;
                    swipeRight = false;
                  },
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: RoundedButton(
                  text: "LOAD OTHER SONGS",
                  textColor: Colors.white,
                  isLoading: false,
                  press: () async {
                    setState(() {
                      currIndex = 0;
                      songImages = [
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                        "https://images.unsplash.com/photo-1612979857678-0ce10e5b3439?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=1350&q=80",
                        "https://images.unsplash.com/photo-1613066839141-4489f60e0389?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80",
                        "https://images.unsplash.com/photo-1613066839141-4489f60e0389?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80",
                        "https://images.unsplash.com/photo-1613098169745-015562f6f27a?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80",
                        "https://images.unsplash.com/photo-1612979857678-0ce10e5b3439?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=1350&q=80",
                        "https://images.unsplash.com/photo-1613066839141-4489f60e0389?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80",
                        "https://images.unsplash.com/photo-1613066839141-4489f60e0389?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=634&q=80"
                      ];
                    });
                  },
                ),
              ),
            ],
          );
  }
}
