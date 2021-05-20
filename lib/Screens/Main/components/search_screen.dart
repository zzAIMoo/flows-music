import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

List<YT_API> results = [];

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  SearchBar searchBar;
  static String key = "AIzaSyBgARzrg0k-ro-BbdTxYfWuwvNtIC6osXA";

  YoutubeAPI ytApi = YoutubeAPI(key);
  List<YT_API> ytResult = [];

  callAPI(String text) async {
    ytResult = await ytApi.search(text);
    results.addAll(ytResult);
    setState(() {});
  }

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

  void onSubmitted(String value) {
    results = [];
    callAPI(value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        _getMoreData();
      }
    });
    callAPI("test");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getMoreData() async {
    if (!isPerformingRequest) {
      setState(() => isPerformingRequest = true);
      List<YT_API> newEntries = await nextPageRequest();
      setState(() {
        results.addAll(newEntries);
        isPerformingRequest = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: Container(
        child: ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, int index) => listItem(index),
          controller: _scrollController,
        ),
      ),
    );
  }

  Widget listItem(index) {
    return Card(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 7.0),
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Image.network(
              results[index].thumbnail['default']['url'],
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Text(
                    results[index].title,
                    softWrap: true,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 1.5)),
                  Text(
                    results[index].channelTitle,
                    softWrap: true,
                  ),
                  /*
              Padding(padding: EdgeInsets.only(bottom: 3.0)),
              Text(
                ytResult[index].url,
                softWrap: true,
              ),
              */
                ]))
          ],
        ),
      ),
    );
  }

  Future<List<YT_API>> nextPageRequest() async {
    List<YT_API> ytResult = await ytApi.nextPage();
    //int to = ytResult.length, from = 0;
    return ytResult;
  }
}
