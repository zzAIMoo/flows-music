import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:flows/components/rounded_button.dart';
import 'card_manager.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class CardScreen extends StatefulWidget {
  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  CardManager _cardManager;
  int currIndex = 0;
  bool swipeLeft = false, swipeRight = false, still = true, requestStarted = false;
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

  //String url = 'https://sechisimone.altervista.org/flows/songs/RADICAL__MINACCIA.mp3';
  String url = 'http://135.125.44.178/songs/a3b44c0172b8c62e9fc621ecbb72bacf.mp3';

  List<String> urls = [
    'https://sechisimone.altervista.org/flows/songs/RADICAL__MINACCIA.mp3',
    "http://135.125.44.178/songs/a3b44c0172b8c62e9fc621ecbb72bacf.mp3"
  ];

  @override
  void initState() {
    super.initState();
    _cardManager = new CardManager(urls[0]);
  }

  @override
  void dispose() {
    _cardManager.dispose();
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
                  animDuration: 200,
                  swipeUp: false,
                  swipeDown: false,
                  orientation: AmassOrientation.BOTTOM,
                  totalNum: songImages.length,
                  stackNum: 3,
                  swipeEdge: 2.2,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.width * 0.9,
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  minHeight: MediaQuery.of(context).size.width * 0.8,
                  //qua dovrò cambiare tutte le cose con le liste, quindi urls, progress e tutto
                  cardBuilder: (context, index) => !swipeLeft && !swipeRight && index == currIndex
                      ? Card(
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 150.0,
                                height: 150.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage('${songImages[index]}'),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: ValueListenableBuilder<ProgressBarState>(
                                  valueListenable: _cardManager.progressNotifier,
                                  builder: (_, value, __) {
                                    return ProgressBar(
                                      onSeek: _cardManager.seek,
                                      progress: value.current,
                                      buffered: value.buffered,
                                      total: value.total,
                                    );
                                  },
                                ),
                              ),
                              ValueListenableBuilder<ButtonState>(
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
                            ],
                          ),
                        )
                      : index != currIndex
                          ? Card(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 150.0,
                                    height: 150.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage('${songImages[index]}'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: ProgressBar(
                                      progress: Duration(seconds: 0),
                                      total: Duration(seconds: 0),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.play_arrow),
                                    iconSize: 32.0,
                                    onPressed: _cardManager.pause,
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
                                        Colors.black,
                                        Colors.grey[400],
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
                                        Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                              fit: BoxFit.fill,
                                              image: new NetworkImage('${songImages[index]}'),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 300,
                                          child: ValueListenableBuilder<ProgressBarState>(
                                            valueListenable: _cardManager.progressNotifier,
                                            builder: (_, value, __) {
                                              return ProgressBar(
                                                onSeek: _cardManager.seek,
                                                progress: value.current,
                                                buffered: value.buffered,
                                                total: value.total,
                                              );
                                            },
                                          ),
                                        ),
                                        ValueListenableBuilder<ButtonState>(
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
                                      ],
                                    ),
                                  ))
                              : ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      stops: [0.0, gradValue / 2, gradValue],
                                      begin: FractionalOffset.topRight,
                                      end: FractionalOffset.bottomLeft,
                                      colors: <Color>[
                                        Colors.purple[300],
                                        Colors.purple[100],
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
                                        Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                              fit: BoxFit.fill,
                                              image: new NetworkImage('${songImages[index]}'),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 300,
                                          child: ValueListenableBuilder<ProgressBarState>(
                                            valueListenable: _cardManager.progressNotifier,
                                            builder: (_, value, __) {
                                              return ProgressBar(
                                                onSeek: _cardManager.seek,
                                                progress: value.current,
                                                buffered: value.buffered,
                                                total: value.total,
                                              );
                                            },
                                          ),
                                        ),
                                        ValueListenableBuilder<ButtonState>(
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
                                      ],
                                    ),
                                  ),
                                ),
                  cardController: controller = CardController(),
                  swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
                    /// Get swiping card's alignment
                    gradValue = (align.x / 10).abs();
                    if (align.x < -1.5) {
                      setState(() {
                        still = false;
                        swipeLeft = true;
                        swipeRight = false;
                      });
                      //Card is LEFT swiping
                    } else if (align.x > 1.5) {
                      setState(() {
                        still = false;
                        swipeLeft = false;
                        swipeRight = true;
                      });
                      //Card is RIGHT swiping
                    } else if (align.x > -1.5 && align.x < 1.5) {
                      setState(() {
                        still = true;
                        swipeLeft = false;
                        swipeRight = false;
                      });
                    }
                  },
                  swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
                    setState(() {
                      if (orientation == CardSwipeOrientation.RIGHT || orientation == CardSwipeOrientation.LEFT) {
                        currIndex++;
                      }
                      still = true;
                      swipeLeft = false;
                      swipeRight = false;
                      _cardManager.setUrl(urls[currIndex]);
                    });
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
                  isLoading: requestStarted,
                  press: () async {
                    setState(() {
                      requestStarted = true;
                      currIndex = 0;
                      songImages = [
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                        "https://cdns.iconmonstr.com/wp-content/assets/preview/2012/240/iconmonstr-sound-wave-4.png",
                      ];
                      requestStarted = false;
                    });
                  },
                ),
              ),
            ],
          );
  }
}
