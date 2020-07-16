import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './Profile.dart';
import './Worker.dart';
import './MyChart.dart';
import './QRCode.dart';
import 'package:myapp/MenuComponent/NewMenu.dart';
import '../LoginPage/auth.dart';


class Account extends StatefulWidget {
  final VoidCallback signOut;
  Map restoData;

  Account({Key key, this.signOut, this.restoData}) : super (key: key);

  @override
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {
  var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int income = 0;
  List orderList = [];
  List incomes = [];

  void initState() {
    super.initState();
    incomes = [0,0,0,0,0];
    orderList = [];
  }

  Widget onLoading() {
    return Scaffold(
      body: Container(
        child: SpinKitFadingCircle(color: Colors.orange, size: 50.0,),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[50], Colors.orange[200], Colors.orange[100], Colors.orange[300]],
            tileMode: TileMode.repeated,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var toProfile = (){
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => MyChart())
      );
    };
    var toWorker = (){
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => Worker(restoData: widget.restoData,)
      ));
    };
    var toQRCode = (){
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => QRCode(restoId: widget.restoData['restaurantId'], restoDocId: widget.restoData['restoDocId']),
      ));
    };
    return StreamBuilder(
      stream: Firestore
        .instance
        .collection('orderList')
        .where('restaurantId', isEqualTo: widget.restoData['restaurantId'])
        .snapshots(),
      builder: (context, snapshot) {
        var date, date2;
        int _temp = 0;
        List _orderList = [], _incomes = [0,0,0,0,0];
        final now = DateTime.now();
        if(!snapshot.hasData) return onLoading();
        for(int i = 0; i < snapshot.data.documents.length; i++) {
          Timestamp t = snapshot.data.documents[i]['date'];
          DateTime d = t.toDate();
          date = DateFormat('yyyy-MM-dd').format(d);
          var difference = DateTime.now().difference(DateTime.parse(date)).inDays;
          // debugPrint('$i: $difference');
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

          if(difference == 0 && snapshot.data.documents[i]['paid'] == 'Paid') {
            int subs = 0;
            List orders = snapshot.data.documents[i]['orders'];
            for(int j = 0; j < orders.length; j++) {
              int price = int.parse(orders[j]['menuprice']) * orders[j]['quantity'];
              subs += price;
            }
            _incomes[4] += subs;
            subs = 0;
          } else if(difference == 1 && snapshot.data.documents[i]['paid'] == 'Paid') {
            int subs = 0;
            List orders = snapshot.data.documents[i]['orders'];
            for(int j = 0; j < orders.length; j++) {
              int price = int.parse(orders[j]['menuprice']) * orders[j]['quantity'];
              subs += price;
            }
            _incomes[3] += subs;
            subs = 0;
          } else if(difference == 2 && snapshot.data.documents[i]['paid'] == 'Paid') {
            int subs = 0;
            List orders = snapshot.data.documents[i]['orders'];
            for(int j = 0; j < orders.length; j++) {
              int price = int.parse(orders[j]['menuprice']) * orders[j]['quantity'];
              subs += price;
            }
            _incomes[2] += subs;
            subs = 0;
          } else if(difference == 3 && snapshot.data.documents[i]['paid'] == 'Paid') {
            int subs = 0;
            List orders = snapshot.data.documents[i]['orders'];
            for(int j = 0; j < orders.length; j++) {
              int price = int.parse(orders[j]['menuprice']) * orders[j]['quantity'];
              subs += price;
            }
            _incomes[1] += subs;
            subs = 0;
          } else if(difference == 4 && snapshot.data.documents[i]['paid'] == 'Paid') {
            int subs = 0;
            List orders = snapshot.data.documents[i]['orders'];
            for(int j = 0; j < orders.length; j++) {
              int price = int.parse(orders[j]['menuprice']) * orders[j]['quantity'];
              subs += price;
            }
            _incomes[0] += subs;
            subs = 0;
          }
          // _orderList.add(snapshot.data.documents[i]);
        }
        // orderList = _orderList;
        
        incomes = _incomes;
        income = _temp;
        _temp = 0;
        // debugPrint('Income: $income');
        // for(int i = 0; i < incomes.length; i++) {
        //   debugPrint('$i: ${incomes[i]}');
        // }

        return Scaffold(
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
                    height: 300,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: MyChart(data: incomes),
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
                          aboutMeBtn(Icons.account_circle, 'Profile', toProfile),
                          // aboutMeBtn(Icons.device_hub, 'Branch'),
                          aboutMeBtn(Icons.people, 'Worker', toWorker),
                          aboutMeBtn(Icons.code, 'QR Code', toQRCode),
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

  Widget aboutMeBtn(IconData iconContent, String nameContent, _onPressed) {
    return InkWell(
      onTap: _onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 0.5, color: Colors.grey),
            bottom: BorderSide(width: 0.5, color: Colors.grey),
          ),
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