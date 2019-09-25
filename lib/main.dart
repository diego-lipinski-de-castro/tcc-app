import 'package:flutter/material.dart';
import 'package:flutter_flipperkit/flutter_flipperkit.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'home.dart';

void main() {
  // timeDilation = 5.0;

  FlipperClient flipperClient = FlipperClient.getDefault();

  flipperClient.addPlugin(new FlipperNetworkPlugin());
  flipperClient.addPlugin(new FlipperSharedPreferencesPlugin());
  
  flipperClient.start();

  runApp(MyApp());
}

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
      home: HomePage(),
    );
  }
}

// Color(0xFF333366)