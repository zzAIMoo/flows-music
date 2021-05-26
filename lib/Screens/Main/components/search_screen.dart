import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:loading_animations/loading_animations.dart';

List<YT_API> results = [];

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false, addedShimmer = false;
  SearchBar searchBar;
  static String key = "AIzaSyBgARzrg0k-ro-BbdTxYfWuwvNtIC6osXA";

  YoutubeAPI ytApi = YoutubeAPI(key, maxResults: 16);
  List<YT_API> ytResult = [];

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Text('Cerca un media'),
      actions: [searchBar.getSearchAction(context)],
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

  callAPI(String text) async {
    ytResult = await ytApi.search(text);
    isPerformingRequest = false;
    setState(() {
      results.addAll(ytResult);
    });
  }

  void onSubmitted(String value) async {
    if (!isPerformingRequest) {
      setState(() {
        _scrollController.jumpTo(0);
        isPerformingRequest = true;
      });
      List<YT_API> newResults = await ytApi.search(value);
      if (newResults.length == 0) {
        showToast(
            "Non esistono video con questo argomento di ricerca, se non trovi una canzone prova ad aggiungere \"Topic\" ai termini di ricerca");
      }
      setState(() {
        isPerformingRequest = false;
        results = newResults;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getMoreData() async {
    if (!isPerformingRequest) {
      setState(() {
        isPerformingRequest = true;
      });
      List<YT_API> newEntries = await ytApi.nextPage();
      if (newEntries == null) {
        isPerformingRequest = false;
        return;
      }
      setState(() {
        isPerformingRequest = false;
        results.addAll(newEntries);
      });
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
          itemBuilder: (_, int index) {
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
          },
          controller: _scrollController,
        ),
      ),
    );
  }

  //Widget shimmerItems(index) {}

  Widget listItem(index) {
    return Card(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 7.0),
        padding: EdgeInsets.all(12.0),
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
                        width: MediaQuery.of(context).size.width / 2.6,
                        child: Text(
                          results[index].title,
                          softWrap: true,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          //results[index].id
                        },
                        color: Color(0xFF6F35A5),
                        textColor: Colors.white,
                        child: Icon(
                          Icons.file_download,
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

  Widget returnShimmer() {
    addedShimmer = true;
    print(addedShimmer);
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
