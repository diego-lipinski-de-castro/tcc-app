import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // void _displaySearch() {
  //   showSearch(context: context, delegate: DataSearch());
  // }

  _openWhats(whatsNumber, context) async {
      final whatsUrl = "https://wa.me/$whatsNumber";

      if(await canLaunch(whatsUrl)) {
        await launch(whatsUrl);
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Não foi possível abrir este número.")));
      }
    }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {

    return GestureDetector(
      onTap: () => _openWhats(document['number'], context),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.0),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text(
                document['eventName'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold
                ),
              ),

              Padding(padding: EdgeInsets.only(top: 5.0)),

              Text(
                document['startPlace'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic
                ),
              ),
            ],
          ),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(10.0)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Início"),
        centerTitle: false,
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: _displaySearch,  
        //   )
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0, bottom: 80.0),
        child: StreamBuilder(
          stream: Firestore.instance.collection('travels').snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) return Text("Carregando...");
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

