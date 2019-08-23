import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'show.dart';

class DataSearch extends SearchDelegate<String> {

  var results = [];
  var suggestions = [];

  @override
  void showResults(BuildContext context) async {
    super.showResults(context);
    await Firestore.instance
          .collection('recent_search')
          .document()
          .setData({
            'text': query,
            'at': DateTime.now().millisecondsSinceEpoch
          });

    var search = await Firestore.instance.collection('travels').where('eventName', isGreaterThanOrEqualTo: query).getDocuments();

    search.documents.forEach((doc) {
      results.add(doc.data);
    });
  }

  @override
  void showSuggestions(BuildContext context) async {
    super.showSuggestions(context);
    var recent = await Firestore.instance.collection('recent_search').orderBy('at', descending: true).getDocuments();

    recent.documents.forEach((doc) {
      suggestions.add(doc.data);
    });

    print(suggestions);
  }

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
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.local_bar),
        title: RichText(
          text:TextSpan(
            text: results[index]['eventName'].substring(0, query.length),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
            children: [
              TextSpan(
                text: results[index]['eventName'].substring(query.length),
                style: TextStyle(
                  color: Colors.black
                )
              )
            ]
          )
        ),
      ),
      itemCount: results.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPage()));  
          },
          leading: Icon(Icons.local_bar),
          title: RichText(
            text:TextSpan(
              text: suggestions[index]['text'].substring(0, query.length),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
              children: [
                TextSpan(
                  text: suggestions[index]['text'].substring(query.length),
                  style: TextStyle(
                    color: Colors.black
                  )
                )
              ]
            )
          ),
        );
      },
      itemCount: suggestions.length,
    );
  }
}