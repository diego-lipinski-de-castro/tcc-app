import 'package:flutter/material.dart';
import 'package:tcc/pages/list_travels.dart';
import 'package:tcc/pages/profile.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Excursão',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Open Sans',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/my-travels': (context) => ListTravelPage(),
      },
    );
  }
}
