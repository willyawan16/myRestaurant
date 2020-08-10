import 'package:flutter/material.dart';
import '../LoginPage/auth.dart';

class Profile extends StatefulWidget {
  Map restoData;
  BaseAuth auth;

  Profile({Key key, this.restoData, this.auth}) : super(key: key);
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Profil Saya'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 100, 20, 0),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  dataTemplate(context, 'Restoran', '${widget.restoData['restaurantName']}'),
                  SizedBox(
                    height: 10,
                  ),
                  dataTemplate(context, 'E-mail', widget.restoData['email']),
                  SizedBox(
                    height: 10,
                  ),
                  dataTemplate(context, 'Banyak Pekerja', widget.restoData['worker'].length.toString()),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    child: Text('Ganti Password?', style: TextStyle(fontSize: 17)),
                    color: Colors.orange[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    onPressed: () {
                      widget.auth.resetPassword(widget.restoData['email']);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Link ganti password telah di send ke email anda'),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget dataTemplate(context, dataName, dataContext) {
    return Container(
      child: new Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width/3,
            child: Text('$dataName', style: TextStyle(fontSize: 17),),
          ),
          // Text(':'),
          Container(
            // width: MediaQuery.of(context).size.width*2/3-20,
            child: Text(': $dataContext', style: TextStyle(fontSize: 17),),
          ),
        ],
      ),
    );
  }
}