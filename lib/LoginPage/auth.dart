import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth{
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
  }

  // Future<String> currentUser() async {
  //   FirebaseUser user = await _auth.currentUser();
  //   return user.uid;
  // }

  Future<String> currentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }
}