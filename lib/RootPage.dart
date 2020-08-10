import 'package:cloud_firestore/cloud_firestore.dart';
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

  String _userId, _email;
  var _userData;
  var _restoData; 

  initState() {
    super.initState();
    // widget.auth.currentUser().then((userId) {
    //   setState((){
    //     authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
    //   });
    // });
    widget.auth.currentUser().then((userId) {
      debugPrint('$userId');
      setState(() {
        authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
        _userId = userId;
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
          email: (val) {
            _email = val.toLowerCase();
          },
          userId: (val){
            _userId = val;
          },
        );
      case AuthStatus.signedIn:
      return StreamBuilder(
        stream: Firestore.instance.collection('user').snapshots(),
        builder: (context, userSnapshot) {
          if(!userSnapshot.hasData) return const Text('Loading');
          Map _temp1= {};
          for(int i = 0; i < userSnapshot.data.documents.length; i++) {
            // if(userSnapshot.data.documents[i]['email'] == _email) {
            if(userSnapshot.data.documents[i]['userId'] == _userId) {
              _userData = userSnapshot.data.documents[i];
              _temp1.addAll({
                'name': userSnapshot.data.documents[i]['name'],
                'email': userSnapshot.data.documents[i]['email'],
                'authority': userSnapshot.data.documents[i]['authority'],
                'userType': userSnapshot.data.documents[i]['userType'],
                'restaurant': userSnapshot.data.documents[i]['restaurant'].path,
              });
              _userData = _temp1;
            }
          }
          _temp1= {};
          return StreamBuilder(
            stream: Firestore.instance.document(_userData['restaurant']).snapshots(),
            builder: (context, restoSnapshot) {
              if(!restoSnapshot.hasData) return const Text('Loading');
              Map _temp2 = {};
              if(_userData['userType'] == 'Main') {
                _temp2.addAll({
                  'restaurantName': restoSnapshot.data['restaurantName'],
                  'email': restoSnapshot.data['email'],
                  'restaurantId': restoSnapshot.data['restaurantId'],
                  // 'city': restoSnapshot.data['city'],
                  // 'address': restoSnapshot.data['address'],
                  // 'addressNo': restoSnapshot.data['addressNo'],
                  // 'branch': restoSnapshot.data['branch'],   
                  'worker': restoSnapshot.data['worker'],    
                  'restoDocId': restoSnapshot.data.documentID,         
                });
                // debugPrint('${_temp2['restoDocId']}');
                _restoData = _temp2;
              } else if(_userData['userType'] == 'Branch'){
                List branchSnapshot = restoSnapshot.data['branch'];

                for(int i = 0; i < branchSnapshot.length; i++) {
                  if(branchSnapshot[i]['email'] == _userData['email']) {
                    _temp2.addAll({
                      'restaurantName': branchSnapshot[i]['restaurantName'],
                      'email': branchSnapshot[i]['email'],
                      'restaurantId': branchSnapshot[i]['restaurantId'],
                      'city': branchSnapshot[i]['city'],
                      'address': branchSnapshot[i]['address'],
                      'addressNo': branchSnapshot[i]['addressNo'],                
                    });
                  }
                }
                _restoData = _temp2;
              }
              _temp2 = {};
              return MyHomePage(
                userId: _userId,
                auth: widget.auth,
                userData: _userData,
                restoData: _restoData,
                onSignedOut: _signedOut,
              );
            },
          );
        }
      );
    }
  }
}