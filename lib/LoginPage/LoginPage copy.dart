import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myapp/LoginPage/createAccountPage.dart';
import './auth.dart';

class LoginPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  Function(String) userId;
  Function(String) email;

  LoginPage({this.auth, this.onSignedIn, this.userId, this.email});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{
  String _email, _password;
  bool hidePassword;
  bool isLoading, failedSignIn;

  final formKey = new GlobalKey<FormState>();

  void initState() {
    super.initState();
    hidePassword = true;
    isLoading = false;
    failedSignIn = false;
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      debugPrint('Form is valid. Email: $_email, Password: $_password');
      return true;
    } else {
      debugPrint('Form is invalid. Email: $_email, Password: $_password');
      return false;
    }
  }

  void validateAndSubmit() async {
    // final FirebaseAuth _auth = FirebaseAuth.instance;
    if(validateAndSave()) {
      try {
        String userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
        // FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: _email, password: _password)).user;
        debugPrint('Signed In: $userId');
        widget.userId(userId);
        widget.email(_email);
        setState(() {
          isLoading = false;
        });
        widget.onSignedIn();
      } catch (e) {
        debugPrint('Error: $e');
        setState(() {
          isLoading = false;
          failedSignIn = true;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Widget onLoading(){
  //   return Center(
  //       child: Card(
  //         elevation: 0,
  //         color: Colors.transparent,
  //         child: SpinKitCubeGrid(
  //           color: Colors.red,
  //           size: 50.0,
  //           // controller: AnimationController(vsync: this,duration: const Duration(milliseconds: 1200)),
  //         ),
  //       ),
  //     );
  // }

  Future<void> _showAskDialog(BuildContext context){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Select user type', style: TextStyle(fontFamily: 'Balsamiq_Sans', fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Main - create master user', style: TextStyle(fontFamily: 'Balsamiq_Sans'),),
                Text('Branch - create branch user', style: TextStyle(fontFamily: 'Balsamiq_Sans'),),
                Text('Worker - create worker', style: TextStyle(fontFamily: 'Balsamiq_Sans'),),
              ],
            ),
          ),
          actions: <Widget>[
            OutlineButton(
              child: Text('Main', style: TextStyle(color: Colors.red, fontFamily: 'Balsamiq_Sans'),),
              highlightedBorderColor: Colors.red,
              highlightColor: Colors.red[100],
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => CreateAccountPage(auth: widget.auth, userType: 'Main',))
                );
                debugPrint('userType: Main');
              },
            ),
            OutlineButton(
              child: Text('Branch', style: TextStyle(color: Colors.yellow[700], fontFamily: 'Balsamiq_Sans'),),
              highlightedBorderColor: Colors.yellow[700],
              highlightColor: Colors.yellow[100],
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => CreateAccountPage(auth: widget.auth, userType: 'Branch',))
                );
                debugPrint('userType: Branch');
              },
            ),
            OutlineButton(
              child: Text('Worker', style: TextStyle(color: Colors.green, fontFamily: 'Balsamiq_Sans'),),
              highlightedBorderColor: Colors.green,
              highlightColor: Colors.green[100],
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => CreateAccountPage(auth: widget.auth, userType: 'Worker',))
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var totHeight = MediaQuery.of(context).size.height;
    var totWidth = MediaQuery.of(context).size.width;
    // debugPrint(isLoading.toString());
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Balsamiq_Sans'
      ),
      home: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
          // setState(() {
          //   isLoading = !isLoading;
          // });
        },
        // child: Scaffold(
        //   backgroundColor: Colors.grey,
        //   body: onLoading(),
        // ),
        // child: onLoading(),
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.grey,
          // body: Container(
          //   child: Column(
          //     children: <Widget>[
          //       Container(
          //         height: totHeight*1/3,
          //         child: Container(),
          //       ),
          //       Container(
          //         height: totHeight*2/3,
          //         width: totWidth,
          //         child: Card(
          //           elevation: 20,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          //           ), 
          //           child: Padding(
          //             padding: EdgeInsets.fromLTRB(40,30,40,0),
          //             child: new Form(
          //               key: formKey,
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.stretch,
          //                 children: <Widget>[
          //                   Text('Login Form', style: TextStyle(fontFamily: 'Sriracha', fontSize: 30, fontWeight: FontWeight.bold),),
          //                   SizedBox(
          //                     height: 10,
          //                   ),
          //                   TextFormField(
          //                     // onChanged: (String str){
          //                     //   setState(() {
          //                     //     email = str;
          //                     //   });
          //                     // },
          //                     validator: (value) => value.isEmpty ? 'Email can\'t be empty': null,
          //                     onSaved: (value) => _email = value,
          //                     decoration: InputDecoration(
          //                       // prefixIcon: Icon(Icons.person),
          //                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          //                       labelText: 'Email',
          //                       labelStyle: TextStyle(fontSize: 17),
          //                     ),
          //                   ),
          //                   SizedBox(
          //                     height: 10,
          //                   ),
          //                   TextFormField(
          //                     // onChanged: (String str){
          //                     //   setState(() {
          //                     //     password = str;
          //                     //   });
          //                     // },
          //                     validator: (value) => value.isEmpty ? 'Password can\'t be empty': null,
          //                     onSaved: (value) => _password = value,
          //                     obscureText: hidePassword,
          //                     decoration: InputDecoration(
          //                       suffixIcon: IconButton(
          //                         icon: Icon(Icons.remove_red_eye),
          //                         onPressed: (){
          //                           setState(() {
          //                             hidePassword = !hidePassword;
          //                           });
          //                         },
          //                       ),
          //                       // prefixIcon: Icon(Icons.),
          //                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          //                       labelText: 'Password',
          //                       labelStyle: TextStyle(fontSize: 17),
          //                     ),
          //                   ),
          //                   SizedBox(
          //                     height: 10,
          //                   ),
          //                   Container(
          //                     // width: totWidth-80,                          
          //                     child: RaisedButton(
          //                       color: Colors.blue[100],
          //                       child: Text('Login', style: TextStyle(fontSize: 20,)),
          //                       shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.all(Radius.circular(10)),
          //                       ),
          //                       onPressed: (){
          //                         FocusScope.of(context).requestFocus(new FocusNode());
          //                         setState(() {
          //                           isLoading = true;
          //                         });
          //                         validateAndSubmit();
          //                       },
          //                     ),
          //                   ),
          //                   Container(
          //                     // width: totWidth-80,                          
          //                     child: FlatButton(
          //                       child: Text('Create an account', style: TextStyle(fontSize: 15,)),
          //                       shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.all(Radius.circular(10)),
          //                       ),
          //                       onPressed: (){
          //                         formKey.currentState.reset();
          //                         setState(() {
          //                           failedSignIn = false;
          //                         });
          //                         _showAskDialog(context);
          //                       },
          //                     ),
          //                   ),
          //                   (isLoading)
          //                   ? SpinKitWave(
          //                     size: 50.0,
          //                     itemBuilder: (BuildContext context, int index){
          //                       return DecoratedBox(
          //                         decoration: BoxDecoration(
          //                           shape: BoxShape.circle,
          //                           color: Colors.red,
          //                         ),
          //                       );
          //                     },
          //                     // controller: AnimationController(vsync: this,duration: const Duration(milliseconds: 1200)),
          //                   )
          //                   : (failedSignIn)
          //                     ? Text('Email or Password might be incorrect', style: TextStyle(color: Colors.red), textAlign: TextAlign.center,)
          //                     : Container(),
          //                 ],
          //               ),
          //             )
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }
}