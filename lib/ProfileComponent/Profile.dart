import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/MenuComponent/NewMenu.dart';
import '../LoginPage/auth.dart';

class Profile extends StatefulWidget {
  final VoidCallback signOut;
  Map restoData;

  Profile({Key key, this.signOut, this.restoData}) : super (key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int income = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore
        .instance
        .collection('orderList')
        .where('restaurantId', isEqualTo: widget.restoData['restaurantId'])
        .snapshots(),
      builder: (context, snapshot) {
        var date;
        int _temp = 0;
        if(!snapshot.hasData) return const Text('Loading...');
        for(int i = 0; i < snapshot.data.documents.length; i++) {
          Timestamp t = snapshot.data.documents[i]['date'];
          DateTime d = t.toDate();
          date = DateFormat('yyyy-MM-dd').format(d);
          if(date == today && snapshot.data.documents[i]['paid'] == 'Paid') {
            int subtotal = 0;
            List orders = snapshot.data.documents[i]['orders'];
            for(int j = 0; j < orders.length; j++) {
              int price = int.parse(orders[j]['menuprice']) * orders[j]['quantity'];
              subtotal += price;
            }
            _temp += subtotal;
            subtotal = 0;
          }
        }
        income = _temp;
        _temp = 0;
        debugPrint('Income: $income');

        return MaterialApp(
          theme: ThemeData(
            fontFamily: 'Balsamiq_Sans',
          ),
          home: Scaffold(
            body: Container(
              padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange[50], Colors.orange[200], Colors.orange[100], Colors.orange[300]],
                  tileMode: TileMode.repeated,
                ),
              ),
              // padding: EdgeInsets.all(100),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Welcome, ${widget.restoData['restaurantName']}', 
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[600]
                        ), 
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        elevation: 5,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                              child: Text('Today\'s Restaurant Income', style: TextStyle(fontSize: 17), textAlign: TextAlign.left,),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10, bottom: 10),
                              child: new Row(
                                children: <Widget>[
                                  Icon(Icons.account_balance_wallet),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Rp$income,00', style:  TextStyle(fontSize: 25),)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Text('About Me', style: TextStyle(fontSize: 17),),
                            ),
                            aboutMeBtn(Icons.account_circle, 'Profile'),
                            aboutMeBtn(Icons.device_hub, 'Branch'),
                            aboutMeBtn(Icons.people, 'Worker'),
                            SizedBox(
                              height: 25,
                            ),
                            RaisedButton(
                              // highlightedBorderColor: Colors.red,
                              color: Colors.red,
                              child: Text('Sign Out', style: TextStyle(fontSize: 20, color: Colors.white),),
                              onPressed: () {
                                signOutDialog();
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // child: FlatButton(
                // child: Text('Logout'),
                // onPressed: () {
                //   widget.signOut();
                // },
              // ),
            ),
          ),
        );
      },
    );
  }

  Future<void> signOutDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Sign Out'),
          content: Text('Want to Sign Out?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No', style: TextStyle(color: Colors.grey),),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            OutlineButton(
              highlightedBorderColor: Colors.orange,
              child: Text('Yes', style: TextStyle(color: Colors.orange),),
              onPressed: (){
                Navigator.of(context).pop();
                widget.signOut();
              },
            ),
          ],
        );
      }
    );
  }

  Widget aboutMeBtn(IconData iconContent, String nameContent) {
    return InkWell(
      onTap: (){
        
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.1),
        ),
        padding: EdgeInsets.fromLTRB(15, 10, 5, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Row(
              children: <Widget>[
                Icon(iconContent),
                SizedBox(
                  width: 10,
                ),
                Text(nameContent),
              ],
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}