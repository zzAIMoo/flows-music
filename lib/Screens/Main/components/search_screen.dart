import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:shimmer/shimmer.dart';

List<YT_API> results = [];

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false, hasStartedSearch = false;
  SearchBar searchBar;
  static String key = "AIzaSyBgARzrg0k-ro-BbdTxYfWuwvNtIC6osXA";

  YoutubeAPI ytApi = YoutubeAPI(key, maxResults: 8);
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
    hasStartedSearch = false;
    setState(() {
      results.addAll(ytResult);
    });
  }

  void onSubmitted(String value) async {
    if (!isPerformingRequest) {
      setState(() {
        isPerformingRequest = true;
      });
      List<YT_API> newResults = await ytApi.search(value);
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
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 80) {
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
      setState(() {
        isPerformingRequest = false;
        results.addAll(newEntries);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("isPerformingRequest: " + isPerformingRequest.toString());
    print("hasStartedSearch: " + hasStartedSearch.toString());
    return Scaffold(
      appBar: searchBar.build(context),
      body: Container(
        child: ListView.builder(
          itemCount: results.length,
          itemBuilder: !isPerformingRequest
              ? (_, int index) => listItem(index)
              : (_, int index) => shimmerItems(index),
          controller: _scrollController,
        ),
      ),
    );
  }

  Widget shimmerItems(index) {
    if (index < 6) {
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
                Padding(padding: EdgeInsets.only(right: 20.0)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), //or 15.0
                  child: Container(
                    height: 10.0,
                    width: 80.0,
                    color: Color(0xffFF0E58),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
