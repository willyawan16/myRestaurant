import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:myapp/OrderComponent/CheckSummary.dart';
import './OrderComponent/Orders.dart';
import './MenuComponent/Menu.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };
  runApp(MyApp());
  //runApp(NewMenu());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute: '/',
      routes: {
        '/menu': (context) => Menu(),
        '/order': (context) => Orders(),
      },
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final _pageOptions = [
    Orders(),
    // CheckOrder(),
    Menu(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pageOptions[_selectedIndex]
      ),
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBorderColor: Colors.transparent,
          selectedItemBackgroundColor: Colors.green,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
          showSelectedItemShadow: false,
          barHeight: 60,
        ),
        selectedIndex: _selectedIndex,
        onSelectTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.assignment_turned_in,
            label: 'Orders',
            selectedBackgroundColor: Colors.green,
          ),
          FFNavigationBarItem(
            iconData: Icons.restaurant_menu,
            label: 'Menu',
            selectedBackgroundColor: Colors.orange,
          ),
          // FFNavigationBarItem(
          //   iconData: Icons.attach_money,
          //   label: 'Purple',
          //   selectedBackgroundColor: Colors.purple,
          // ),
          // FFNavigationBarItem(
          //   iconData: Icons.note,
          //   label: 'Blue',
          //   selectedBackgroundColor: Colors.blue,
          // ),
          // FFNavigationBarItem(
          //   iconData: Icons.settings,
          //   label: 'Red Item',
          //   selectedBackgroundColor: Colors.red,
          // ),
        ],
      ),
    );
  }
}

