import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/LoginPage/auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RecoveryPage extends StatefulWidget {
  BaseAuth auth;

  RecoveryPage({Key key, this.auth}) : super(key: key);
  @override
  _RecoveryPageState createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {

  String _email;
  List userEmail = [];
  bool isLoading;
  final formKey = new GlobalKey<FormState>();

  void initState() {
    super.initState();
    isLoading = false;
    userEmail = [];
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      debugPrint('Form is valid. Email: $_email');
      return true;
    } else {
      debugPrint('Form is invalid. Email: $_email');
      return false;
    }
  }

  void validateAndSubmit() async {
    // final FirebaseAuth _auth = FirebaseAuth.instance;
    if(validateAndSave()) {
      try {
        widget.auth.resetPassword(_email);
        debugPrint('${emailExist(_email)}');
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        debugPrint('Error: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool emailExist(value) {
    bool exist = false;
    for(int i = 0; i < userEmail.length; i++) {
      if(value == userEmail) {
        exist = true;
      }
    }

    return exist;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('user').snapshots(),
      builder: (context, snapshot) {
        List _userEmail = [];
        if(!snapshot.hasData) return const Text('Loading');
        for(int i = 0; i < snapshot.data.documents.length; i++) {
          _userEmail.add(snapshot.data.documents[i]['email']);
        }
        userEmail = _userEmail;
        _userEmail = [];

        return Scaffold(
          backgroundColor: Colors.orange[50],
          appBar: AppBar(
            title: Text('Password Recovery'),
            backgroundColor: Colors.orange,
          ),
          body: Container(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Please type your registered email, recovery link will be send.',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                SizedBox(
                  height: 10
                ),
                new Form(
                  key: formKey,
                  child: TextFormField(
                    validator: (value) => 
                      value.isEmpty 
                      ? 'Please type your Email' 
                      : value.indexOf('@') == -1 && value.indexOf('.com') == -1
                        ? 'Wrong format'
                        : !emailExist(value)
                          ? 'Email not Found'
                          : null,
                    onSaved: (value) => _email = value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'Registered Email',
                      labelStyle: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10
                ),
                RaisedButton(
                  color: Colors.orange[200],
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  child: Text('Send Link'),
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    validateAndSubmit();
                    
                  },
                ),
                SizedBox(
                  height: 10
                ),
                (isLoading)
                ? SpinKitSpinningCircle(
                  color: Colors.orange,
                  size: 50.0,
                )
                : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}