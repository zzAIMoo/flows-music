import 'package:flows/Screens/Login/login_screen.dart';
import 'package:flows/Screens/Main/components/card_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<YT_API> results = [];

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false, downloadStarted = false, isPlaying = false;
  SearchBar searchBar;
  static String key = "AIzaSyBgARzrg0k-ro-BbdTxYfWuwvNtIC6osXA";
  String accessToken = "", refreshToken = "", lastSearch = "";
  CardManager _cardManager;

  YoutubeAPI ytApi = YoutubeAPI(key, maxResults: 12, type: "video");
  List<YT_API> ytResult = [];
  List<bool> doesItExist = [];
  List<String> doesItExistString = [];

  void doStuff() async {
    getSharedPrefs().then((value) async {
      print(doesItExistString);
      Future.forEach(doesItExistString, (element) {
        if (element == "1") {
          doesItExist.add(true);
        } else {
          doesItExist.add(false);
        }
      }).then((value) {
        setState(() {});
      });
    });
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("access_token");
    if (prefs.containsKey("does_it_exist")) {
      doesItExistString.addAll(prefs.getStringList("does_it_exist"));
    }
    print("access-token:" + accessToken);
    refreshToken = prefs.getString("refresh_token");
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text('Cerca un media'),
      backgroundColor: Color(0xFF6F35A5),
      foregroundColor: Colors.white,
      actions: [!isPerformingRequest ? searchBar.getSearchAction(context) : Container()],
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  _SearchScreenState() {
    searchBar = new SearchBar(
      inBar: true,
      setState: setState,
      onSubmitted: onSubmitted,
      buildDefaultAppBar: buildAppBar,
    );
  }

  void onSubmitted(String value) async {
    doesItExist.clear();
    doesItExistString.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("last_search", value);
    if (!isPerformingRequest) {
      setState(() {
        isPerformingRequest = true;
        _scrollController.jumpTo(0);
      });
      List<YT_API> newResults = await ytApi.search(value);
      if (newResults.length == 0) {
        return;
      }
      results = newResults;
      int i = doesItExist.length;
      Future.forEach(results, (element) async {
        await songExists(i);
        i++;
      }).then((value) {
        prefs.setStringList("does_it_exist", doesItExistString);
        setState(() {
          isPerformingRequest = false;
        });
      });

      setState(() {});
    }
  }

  checkIfEquivalent(List<bool> array1, List<YT_API> array2) {
    return array1.length == array2.length;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        _getMoreData();
      }
    });
    doesItExist.clear();
    doesItExistString.clear();
    doStuff();
    //_cardManager = new CardManager("http://135.125.44.178/songs/a3b44c0172b8c62e9fc621ecbb72bacf.mp3");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getMoreData() async {
    doesItExist.clear();
    doesItExistString.clear();
    if (!isPerformingRequest) {
      setState(() {});
      List<YT_API> newEntries = await ytApi.nextPage();
      if (newEntries == null) {
        return;
      }
      results.addAll(newEntries);
      int i = doesItExist.length;
      print("lunghezza: " + doesItExist.length.toString());
      Future.forEach(newEntries, (element) async {
        await songExists(i);
        i++;
      }).then((value) {
        setState(() {
          isPerformingRequest = false;
        });
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print("isPerformingRequest: " + isPerformingRequest.toString());
    return Scaffold(
      appBar: searchBar.build(context),
      body: Container(
        child: ListView.builder(
          itemCount: results.length,
          itemBuilder: !isPerformingRequest
              ? (_, int index) {
                  if (index == results.length - 1) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                        ),
                        Center(
                          child: Container(
                            child: LoadingRotating.square(
                              size: 10.0,
                              borderColor: Color(0xFF6F35A5),
                              backgroundColor: Color(0xFF6F35A5),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                        ),
                      ],
                    );
                  } else {
                    return listItem(index);
                  }
                }
              : (_, int index) => (returnShimmer()),
          controller: _scrollController,
        ),
      ),
    );
  }

  Widget listItem(index) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        padding: EdgeInsets.only(left: 12.0, top: 10, right: 12),
        child: Row(
          children: <Widget>[
            Image.network(
              results[index].thumbnail['default']['url'],
              width: 100,
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3.8,
                        child: Text(
                          results[index].title,
                          softWrap: true,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      /*PopupMenuButton(
                        shape: CircleBorder(side: BorderSide(width:15)),
                        itemBuilder: (context) {
                          List<PopupMenuEntry<Object>> list = [];
                          list.add(
                            PopupMenuItem(child: Text('Add Playlist'), value: 1),
                          );
                        },
                      ),*/
                      PopupMenuButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        itemBuilder: (BuildContext bc) => [
                          PopupMenuItem(child: Text("Add to favourites!"), value: "add_to_favourites"),
                        ],
                        onSelected: (value) {
                          handleFunctions("Add to favourites", results[index].id);
                        },
                      ),
                      doesItExist.length == 0
                          ? Container()
                          : !doesItExist[index]
                              ? !downloadStarted
                                  ? MaterialButton(
                                      onPressed: () {
                                        print(index);
                                        addSong(index);
                                      },
                                      color: Color(0xFF6F35A5),
                                      textColor: Colors.white,
                                      child: Icon(
                                        Icons.file_download,
                                        size: 16,
                                      ),
                                      shape: CircleBorder(),
                                    )
                                  : Center(
                                      child: Container(
                                        padding: EdgeInsets.only(left: 15),
                                        child: LoadingRotating.square(
                                          size: 10.0,
                                          borderColor: Color(0xFF6F35A5),
                                          backgroundColor: Color(0xFF6F35A5),
                                        ),
                                      ),
                                    )
                              : !isPlaying
                                  ? MaterialButton(
                                      onPressed: () {
                                        print(index);
                                        startSong(results[index].id);
                                      },
                                      color: Color(0xFF6F35A5),
                                      textColor: Colors.white,
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 16,
                                      ),
                                      shape: CircleBorder(),
                                    )
                                  : MaterialButton(
                                      onPressed: () {
                                        print(index);
                                        _cardManager.pause();
                                        isPlaying = false;
                                        setState(() {});
                                      },
                                      color: Color(0xFF6F35A5),
                                      textColor: Colors.white,
                                      child: Icon(
                                        Icons.pause,
                                        size: 16,
                                      ),
                                      shape: CircleBorder(),
                                    ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 1.5)),
                  Text(
                    results[index].channelTitle,
                    softWrap: true,
                    style: TextStyle(fontSize: 10.0),
                  ),
                  /*
              Padding(padding: EdgeInsets.only(bottom: 3.0)),
              Text(
                ytResult[index].url,
                softWrap: true,
              ),
              */
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  dynamic handleFunctions(String value, String id) {
    handleClick(value, id);
  }

  void handleClick(String value, String id) async {
    switch (value) {
      case 'Add to favourites':
        var addToPlaylistUrl = Uri.parse("https://api.flowsmusic.it/create/add_to_playlist.php");
        String songFileLink = md5.convert(convert.utf8.encode(id)).toString();
        var responseAddToPlaylist = await http.post(
          addToPlaylistUrl,
          body: {
            "access_token": accessToken,
            "song_file_name": songFileLink,
            "playlist_name": "favourites",
          },
        );
        if (responseAddToPlaylist.statusCode == 200) {
          print(responseAddToPlaylist.body);
          var responseParsed = convert.jsonDecode(responseAddToPlaylist.body);
          if (responseParsed["response_type"] == "song_added_to_playlist") {
            showToast("Song added correctly to your favourites");
          } else if (responseParsed["response_type"] == "error_in_adding") {
            showToast("There was an error adding the song, please retry");
          }
          break;
        }
    }
  }

  void startSong(String id) {
    isPlaying = true;
    _cardManager = new CardManager("http://135.125.44.178/songs/" + md5.convert(convert.utf8.encode(id)).toString() + ".mp3");
    _cardManager.play();
    setState(() {});
  }

  Future<bool> songExists(int index) async {
    var checkSongUrl = Uri.parse("https://api.flowsmusic.it/read/check_song.php");
    print(md5.convert(convert.utf8.encode(results[index].id)).toString());
    var responseCheckSong = await http.post(
      checkSongUrl,
      body: {
        "access_token": accessToken,
        "song_file_name": md5.convert(convert.utf8.encode(results[index].id)).toString(),
      },
    );
    if (responseCheckSong.statusCode == 200) {
      var parsedCheckSong = convert.jsonDecode(responseCheckSong.body);
      if (parsedCheckSong["response_type"] == "song_exists") {
        doesItExist.add(true);
        doesItExistString.add("1");
        return true;
      } else if (parsedCheckSong["response_type"] == "song_not_exists") {
        doesItExist.add(false);
        doesItExistString.add("0");
        return false;
      } else if (parsedCheckSong["response_type"] == "access_token_expired") {
        var url = Uri.parse('https://api.flowsmusic.it/OAuth/get_access_token.php');
        var response = await http.post(url, body: {
          'refresh_token': refreshToken,
        });
        if (response.statusCode == 200) {
          var responseParsed = convert.jsonDecode(response.body);
          if (responseParsed["response_type"] == "access_token_created_correctly") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token', responseParsed["response_body"]["access_token"]).then((value) {
              songExists(index);
            });
          } else if (responseParsed["response_type"] == "refresh_token_expired") {
            showToast("Token Expired, logging out of the account");
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            downloadStarted = false;
            setState(() {});
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
              (Route route) => false,
            );
            return false;
          }
        }
        return false;
      }
      return false;
    }
    return false;
  }

  void addSong(int index) async {
    String artistName = "";
    downloadStarted = true;
    setState(() {});
    List<String> tags = [];
    var lastfmUrl = Uri.encodeFull("https://ws.audioscrobbler.com/2.0/?method=artist.gettoptags&autocorrect=1&artist=" +
        results[index].channelTitle.toLowerCase().replaceAll("vevo", "").replaceAll("- Topic", "") +
        "&api_key=4d70550343db4aa79b0f2fc6c5a9867b&format=json&autocorrect=1");
    var responseFM = await http.get(lastfmUrl);
    if (responseFM.statusCode == 200) {
      var responseParsed = convert.jsonDecode(responseFM.body);
      if (responseParsed["error"] == 6 || responseParsed["toptags"].length == 2) {
        results[index].title.split(" -").forEach((element) async {
          var url = Uri.encodeFull("https://ws.audioscrobbler.com/2.0/?method=artist.gettoptags&autocorrect=1artist=" +
              element.replaceAll(" ", "+") +
              "&api_key=4d70550343db4aa79b0f2fc6c5a9867b&format=json&autocorrect=1");
          var responseInside = await http.get(url);
          if (responseInside.statusCode == 200) {
            var parsed = convert.jsonDecode(responseInside.body);
            if (parsed["error"] != 6) {
              artistName = element;
              parsed["toptags"]["tag"].forEach((element) {
                if (element["count"] >= 70) {
                  tags.add(element["name"]);
                }
              });
            }
          }
          String tagsForRequest = "";
          tags.forEach((element) {
            tagsForRequest += element.toString() + " ";
          });
          var addSongUrl = Uri.parse("https://api.flowsmusic.it/create/add_song.php");
          var responseAddSong = await http.post(
            addSongUrl,
            body: {
              "access_token": accessToken,
              "song_file_name": md5.convert(convert.utf8.encode(results[index].id)).toString(),
              "song_name": results[index].title,
              "artist_name": artistName,
              "artist_tags": tagsForRequest,
            },
          );
          if (responseAddSong.statusCode == 200) {
            print(responseAddSong.body);
            var parsedAddSong = convert.jsonDecode(responseAddSong.body);
            print(parsedAddSong);
            if (parsedAddSong["response_type"] == "song_added") {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('access_token', parsedAddSong["response_body"]["access_token"].toString());
              setState(() {
                doesItExist[index] = true;
              });
              var downloadUrl = Uri.parse('http://135.125.44.178:5000/url?id=' + results[index].id);
              var responseDownload = await http.get(downloadUrl);
              print('Response status: ${responseDownload.statusCode}');
              print('Response body: ${responseDownload.body}');
              if (responseDownload.statusCode == 200) {
                print(responseDownload);
                downloadStarted = false;
              }
              return;
            } else if (parsedAddSong["response_type"] == "artist_already_exists") {
              showToast("L'artista già esiste, come hai datto ad ottenere questo errore");
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('access_token', parsedAddSong["response_body"]["access_token"].toString());
              downloadStarted = false;
              setState(() {});
              return;
            } else if (parsedAddSong["response_type"] == "song_already_exists") {
              downloadStarted = false;
              showToast("La canzone già esiste sul database, come hai fatto ad ottenere questo errore");
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('access_token', parsedAddSong["response_body"]["access_token"].toString());
              setState(() {});
              return;
            } else if (parsedAddSong["response_type"] == "access_token_expired") {
              var url = Uri.parse('https://api.flowsmusic.it/OAuth/get_access_token.php');
              var response = await http.post(url, body: {
                'refresh_token': refreshToken,
              });
              if (response.statusCode == 200) {
                var responseParsed = convert.jsonDecode(response.body);
                if (responseParsed["response_type"] == "access_token_created_correctly") {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('access_token', responseParsed["response_body"]["access_token"]).then((value) {
                    addSong(index);
                  });
                } else if (responseParsed["response_type"] == "refresh_token_expired") {
                  showToast("Token Expired, logging out of the account");
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.clear();
                  downloadStarted = false;
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
          downloadStarted = false;
          setState(() {});
        });
      } else {
        artistName = results[index].channelTitle.toLowerCase().replaceAll("vevo", "").replaceAll("- Topic", "");
        responseParsed["toptags"]["tag"].forEach((element) {
          if (element["count"] >= 70) {
            tags.add(element["name"]);
          }
        });
        String tagsForRequest = "";
        tags.forEach((element) {
          tagsForRequest += element.toString() + " ";
        });
        var addSongUrl = Uri.parse("https://api.flowsmusic.it/create/add_song.php");
        var responseAddSong = await http.post(
          addSongUrl,
          body: {
            "access_token": accessToken,
            "song_file_name": md5.convert(convert.utf8.encode(results[index].title)).toString(),
            "song_name": results[index].title,
            "artist_name": artistName,
            "artist_tags": tagsForRequest,
          },
        );
        if (responseAddSong.statusCode == 200) {
          var parsedAddSong = convert.jsonDecode(responseAddSong.body);
          print(parsedAddSong);
          if (parsedAddSong["response_type"] == "song_added") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token', responseParsed["response_body"]["access_token"].toString());
            setState(() {
              doesItExist[index] = true;
            });
            var downloadUrl = Uri.parse('http://135.125.44.178:5000/url?id=' + results[index].id);
            var responseDownload = await http.get(downloadUrl);
            print('Response status: ${responseDownload.statusCode}');
            print('Response body: ${responseDownload.body}');
            if (responseDownload.statusCode == 200) {
              print(responseDownload);
              downloadStarted = false;
            }
            return;
          } else if (parsedAddSong["response_type"] == "error_in_adding") {
            showToast("C'è stato un errore nel download della canzone");
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('access_token', responseParsed["response_body"]["access_token"].toString());
            downloadStarted = false;
            setState(() {});
            return;
          } else if (parsedAddSong["response_type"] == "access_token_expired") {
            var url = Uri.parse('https://api.flowsmusic.it/OAuth/get_access_token.php');
            var response = await http.post(url, body: {
              'refresh_token': refreshToken,
            });
            if (response.statusCode == 200) {
              var responseParsed = convert.jsonDecode(response.body);
              print(responseAddSong);
              if (responseParsed["response_type"] == "access_token_created_correctly") {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('access_token', responseParsed["response_body"]["access_token"]).then((value) {
                  addSong(index);
                });
              } else if (responseParsed["response_type"] == "refresh_token_expired") {
                showToast("Token Expired, logging out of the account");
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                downloadStarted = false;
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
            if (responseAddSong.statusCode == 200) {
              var parsedAddSong = convert.jsonDecode(responseAddSong.body);
              print(parsedAddSong);
              if (parsedAddSong["response_type"] == "song_added") {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('access_token', parsedAddSong["response_body"]["access_token"].toString());
                print("ciao" + parsedAddSong);
                setState(() {
                  doesItExist[index] = true;
                });
                var downloadUrl = Uri.parse('http://135.125.44.178:5000/url?id=' + results[index].id);
                var responseDownload = await http.get(downloadUrl);
                print('Response status: ${responseDownload.statusCode}');
                print('Response body: ${responseDownload.body}');
                if (responseDownload.statusCode == 200) {
                  print(responseDownload);
                  downloadStarted = false;
                }
                return;
              } else if (parsedAddSong["response_type"] == "artist_already_exists") {
                showToast("L'artista già esiste, come hai datto ad ottenere questo errore");
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('access_token', parsedAddSong["response_body"]["access_token"].toString());
                downloadStarted = false;
                print("primo" + parsedAddSong);
                setState(() {});
                return;
              } else if (parsedAddSong["response_type"] == "song_already_exists") {
                downloadStarted = false;
                showToast("La canzone già esiste sul database, come hai fatto ad ottenere questo errore");
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('access_token', parsedAddSong["response_body"]["access_token"].toString());
                print("lmao" + parsedAddSong);
                setState(() {});
                return;
              } else if (parsedAddSong["response_type"] == "access_token_expired") {
                var url = Uri.parse('https://api.flowsmusic.it/OAuth/get_access_token.php');
                var response = await http.post(url, body: {
                  'refresh_token': refreshToken,
                });
                if (response.statusCode == 200) {
                  var responseParsed = convert.jsonDecode(response.body);
                  if (responseParsed["response_type"] == "access_token_created_correctly") {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString('access_token', responseParsed["response_body"]["access_token"]).then((value) {
                      addSong(index);
                    });
                  } else if (responseParsed["response_type"] == "refresh_token_expired") {
                    showToast("Token Expired, logging out of the account");
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.clear();
                    downloadStarted = false;
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
          downloadStarted = false;
        }
        downloadStarted = false;
      }
      downloadStarted = false;
    }
  }

  Widget returnShimmer() {
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
              Padding(padding: EdgeInsets.only(right: 15.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0), //or 15.0
                    child: Container(
                      height: 14.0,
                      width: MediaQuery.of(context).size.width / 2,
                      color: Color(0xffFF0E58),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0), //or 15.0
                    child: Container(
                      height: 8.0,
                      width: 20,
                      color: Color(0xffFF0E58),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
}
