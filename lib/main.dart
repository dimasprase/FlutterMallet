import 'package:flutter/material.dart';
import 'package:iele_testnet/util/constants.dart';
import 'package:iele_testnet/activity/splashscreen.dart';
import 'package:iele_testnet/activity/listaccounts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light,
          primaryColor: new Color(0xFF003366),
          accentColor: Colors.blueAccent),
      home: SplashScreen(),
      routes: getRoutes(),
    );
  }

  Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      ANIMATED_SPLASH: (BuildContext context) => new SplashScreen(),
      LIST_ACCOUNT: (BuildContext context) => new ListAcounts()
    };
  }
}