import 'package:flutter/material.dart';
import '../LoginPage/auth.dart';

class Profile extends StatefulWidget {
  final VoidCallback signOut;

  Profile({Key key, this.signOut}) : super (key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(100),
        child: FlatButton(
          child: Text('Logout'),
          onPressed: () {
            widget.signOut();
          },
        ),
      ),
    );
    // return Scaffold(
    //   body: ,
    // );
  }
}