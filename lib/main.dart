import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './OrderComponent/Orders.dart';
import './MenuComponent/Menu.dart';
import './LoginPage/LoginPage.dart';
import './LoginPage/auth.dart';
import './RootPage.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Balsamiq_Sans',
      ),
      // initialRoute: '/',
      routes: {
        '/menu': (context) => Menu(),
        '/order': (context) => Orders(),
      },
      // home: MyHomePage(),
      home: new RootPage(auth: new Auth()),
    );
  }
}



