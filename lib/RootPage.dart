import 'package:flutter/material.dart';
import './LoginPage/LoginPage.dart';
import './LoginPage/auth.dart';
import 'HomePage.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  RootPageState createState() => RootPageState();
}

enum AuthStatus{
  notSignedIn,
  signedIn
}

class RootPageState extends State<RootPage> {

  AuthStatus authStatus = AuthStatus.notSignedIn;

  String _userId;

  initState() {
    super.initState();
    // widget.auth.currentUser().then((userId) {
    //   setState((){
    //     authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
    //   });
    // });
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    }).catchError((onError){
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }
  
  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
          userId: (val){
            _userId = val;
          },
        );
      case AuthStatus.signedIn:
        return MyHomePage(
          userId: _userId,
          auth: widget.auth,
          onSignedOut: _signedOut,
        );
    }
  }
}