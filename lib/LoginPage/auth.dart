import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

class Auth implements BaseAuth{
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = (await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
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

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }
}