import 'package:flutter/material.dart';
import 'show.dart';

class DataSearch extends SearchDelegate<String> {

  final fakeData = ["1","2","3","4","5"];

  final results = [];

  final recentQueries = ["1","2","3"];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    final suggestionList = query.isEmpty
      ? recentQueries
      : fakeData.where((i) => i.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPage()));  
          // showResults(context);
        },
        leading: Icon(Icons.local_bar),
        title: RichText(
          text:TextSpan(
            text: suggestionList[index].substring(0, query.length),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
            children: [
              TextSpan(
                text: suggestionList[index].substring(query.length),
                style: TextStyle(
                  color: Colors.black
                )
              )
            ]
          )
        ),
      ),
      itemCount: suggestionList.length,
    );

  }

}