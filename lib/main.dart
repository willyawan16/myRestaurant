import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './OrderComponent/Orders.dart';
import './MenuComponent/Menu.dart';
import './LoginPage/LoginPage.dart';
import './LoginPage/auth.dart';
import './RootPage.dart';
import './RootPageForWorker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };
  // setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('id', 'ID'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'myResto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Balsamiq_Sans',
      ),
      // home: MyHomePage(),
      // home: new RootPage(auth: new Auth()),
      home: SelectionPage(),
    );
  }
}

class SelectionPage extends StatefulWidget {
  @override
  SelectionPageState createState() => SelectionPageState();
}

class SelectionPageState extends State<SelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 2 / 5,
              // width: MediaQuery.of(context).size.width * 2,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(300), 
                  // bottomRight: Radius.circular(150),
                )
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30, 70, 30, 0),
              // color: Colors.pink,
              child: Text('Masuk sebagai..', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30, 10, 30, 50),
              // color: Colors.red,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RaisedButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => new RootPage(auth: new Auth()),)
                      );
                    },
                    child: Text('Admin Restoran'),
                    color: Colors.orange[100],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RaisedButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => new RootPageForWorker(),)
                      );
                    },
                    child: Text('Pelayan Restoran'),
                    color: Colors.orange[100],
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              width: 100,
              // padding: EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Colors.orange,
              ), 
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  // border: Border.all(color: Colors.orange[50]),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(150), 
                    // topRight: Radius.circular(500),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                // height: MediaQuery.of(context).size.height / 3,
                // width: MediaQuery.of(context).size.width * 2,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    // topLeft: Radius.circular(150), 
                    topRight: Radius.circular(500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



