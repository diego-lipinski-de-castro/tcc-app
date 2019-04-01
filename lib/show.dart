import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class ShowPage extends StatefulWidget {
  ShowPage({Key key}) : super(key: key);

  @override
  _ShowPageState createState() => _ShowPageState();
}

class _ShowPageState extends State<ShowPage> {

  @override
  void initState() {
    super.initState();

    Firestore.instance
      .collection('travels')
      .document('Lb3zbJwF7RYINJLa6gu')
      .get()
      .then((DocumentSnapshot snapshot) => {
        log('$snapshot')
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teste 2"),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
               
          ],
        ),
      ),
    );
  }
}
