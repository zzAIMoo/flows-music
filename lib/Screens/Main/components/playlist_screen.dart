import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flows/Screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'library_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:marquee/marquee.dart';

class PlaylistScreen extends StatefulWidget {
  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

// use GetIt or Provider rather than a global variable in a real project
PageManager _pageManager;

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<String> titles = [];
  List<String> songs = [];
  String playlistName = "", accessToken = "", refreshToken = "";
  bool requestStarted = false;

  Future<void> getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    playlistName = prefs.getString("playlist_name");
    accessToken = prefs.getString("access_token");
    refreshToken = prefs.getString("refresh_token");
    setState(() {});
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

  Future<void> initPlaylist() async {
    getPrefs().then((value) async {
      var url = Uri.parse('https://api.flowsmusic.it/read/get_playlist_songs.php');
      var response = await http.post(url, body: {
        'access_token': accessToken,
        'playlist_name': playlistName,
      });
      if (response.statusCode == 200) {
        var responseParsed = convert.jsonDecode(response.body);
        print(responseParsed);
        if (responseParsed["response_type"] == "received_correctly") {
          var parsedSongs = responseParsed["response_body"]["playlist"];
          //int length = responseParsed["response_body"]["playlist"].length;
          Future.forEach(parsedSongs, (element) {
            titles.add(element["song_name"]);
            songs.add(element["song_file_link"] + ".mp3");
          }).then((value) {
            print(titles);
            print(songs);
            _pageManager = PageManager(titles, songs);
            setState(() {});
          });
        } else if (responseParsed["response_type"] == "error_in_retrieving") {
          print(responseParsed);
          showToast("There has been an error in retrieving your playlists");
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
                initPlaylist();
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
    });
  }

  doStuff() async {
    await initPlaylist();
  }

  @override
  void initState() {
    super.initState();
    doStuff();
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Column(
        children: [
          Playlist(),
          CurrentSongTitle(),
          AudioProgressBar(),
          AudioControlButtons(),
        ],
      ),
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Container(
            height: 50.0,
            color: Colors.white,
            child: Marquee(
              velocity: 60,
              blankSpace: 4,
              text: title,
            ),
          ),
        );
      },
    );
  }
}

class Playlist extends StatelessWidget {
  const Playlist({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: _pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  shadowColor: Colors.grey[200],
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    focusColor: Colors.grey[200],
                    highlightColor: Colors.grey[200],
                    splashColor: Colors.grey[200],
                    onTap: () {
                      _pageManager.seekIndex(index);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 7.0),
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(right: 20.0)),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${playlistTitles[index]}",
                                  softWrap: true,
                                  style: TextStyle(fontSize: 18.0),
                                  overflow: TextOverflow.ellipsis,
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
            },
          );
        },
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _pageManager.progressNotifier,
      builder: (_, value, __) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: ProgressBar(
            progressBarColor: Color(0xFF6F35A5),
            thumbColor: Color(0xFF6F35A5),
            baseBarColor: Color(0xFFDBC7ED),
            thumbGlowColor: Color(0xFF6F35A5),
            bufferedBarColor: Color(0xFFBF8EED),
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
            onSeek: _pageManager.seek,
          ),
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RepeatButton(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RepeatState>(
      valueListenable: _pageManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = Icon(Icons.repeat, color: Colors.grey);
            break;
          case RepeatState.repeatSong:
            icon = Icon(Icons.repeat_one);
            break;
          case RepeatState.repeatPlaylist:
            icon = Icon(Icons.repeat);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: _pageManager.onRepeatButtonPressed,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Icon(Icons.skip_previous),
          onPressed: (isFirst) ? null : _pageManager.onPreviousSongButtonPressed,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: _pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(
                backgroundColor: Color(0xFF6F35A5),
                valueColor: AlwaysStoppedAnimation(Color(0xFFBF8EED)),
              ),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: _pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: _pageManager.pause,
            );
          default:
            return Container();
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: Icon(Icons.skip_next),
          onPressed: (isLast) ? null : _pageManager.onNextSongButtonPressed,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled) ? Icon(Icons.shuffle) : Icon(Icons.shuffle, color: Colors.grey),
          onPressed: _pageManager.onShuffleButtonPressed,
        );
      },
    );
  }
}
