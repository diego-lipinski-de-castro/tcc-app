import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tcc/pages/add_travel.dart';
import 'package:tcc/pages/list_travels.dart';
import 'package:tcc/pages/profile.dart';
import 'home.dart';

void main() {
  // Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  // Crashlytics.instance.log('');
  // Crashlytics.instance.crash();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    // analytics.logAppOpen();
    // analytics.logEvent();
    // analytics.setUserId(id);
    // analytics.setUserProperty();
    // analytics.setCurrentScreen();

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
        '/add-travel': (context) => AddTravelPage(),
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics)
      ],
    );
  }
}
