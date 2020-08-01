import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:myapp/LoginPage/auth.dart';
import './OrderComponent/Orders.dart';
import './MenuComponent/Menu.dart';
import './AccountComponent/Account.dart';
import './LoginPage/auth.dart';
import 'VerifyComponent/VerifyPage.dart';

class MyHomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  String userId;
  Map userData, restoData;

  MyHomePage({Key key, @required this.userId, this.auth, this.onSignedOut, this.userData, this.restoData}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 3;
  List _pageOptions, waitingList = [];
  Map userData, restoData;
  
  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch(e) {
      print(e);
    }
  }
  
  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    restoData = widget.restoData;
    _pageOptions = [
      Orders(restoId: widget.restoData['restaurantId'], restoDocId: widget.restoData['restoDocId'],),
      // CheckOrder(),
      Menu(restoId: widget.restoData['restaurantId'],),
      VerifyPage(restoId: widget.restoData['restaurantId'],),
      Account(signOut: _signOut, restoData: widget.restoData),
    ];
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
  Widget build(BuildContext context){
    // debugPrint(widget.userData.toString());
    // debugPrint(widget.restoData.toString());
    return StreamBuilder(
      stream: Firestore.instance.collection('orderList').where('restaurantId', isEqualTo: widget.restoData['restaurantId']).snapshots(),
      builder: (context, snapshot) {
        List _waitingList = [];
        Map _temp = {};
        var today, date, time;
        if(!snapshot.hasData) return onLoading();
        for(int i = 0; i < snapshot.data.documents.length; i++) {
          Timestamp t = snapshot.data.documents[i]['date'];
          DateTime d = t.toDate();
          today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          date = DateFormat('yyyy-MM-dd').format(d);
          time = DateFormat('h:mm a').format(d);
          if(snapshot.data.documents[i]['verified'] == false && date == today) {
            _temp.addAll({
              'name': snapshot.data.documents[i]['customer'],
              'status': snapshot.data.documents[i]['status'],
              'orderNum': snapshot.data.documents[i]['orderNum'],
              'time': time,
              'createdBy': snapshot.data.documents[i]['createdBy'],
              'docId': snapshot.data.documents[i].documentID,
              'made': false
            });
            _waitingList.add(_temp);
          } else if(snapshot.data.documents[i]['verified'] == true && date == today && snapshot.data.documents[i]['additionalOrders'].isNotEmpty) {
            Timestamp t2 = snapshot.data.documents[i]['additionalOrders'][snapshot.data.documents[i]['additionalOrders'].length-1]['time'];
            DateTime d2 = t2.toDate();
            var time2 = DateFormat('h:mm a').format(d2);
            if(snapshot.data.documents[i]['verified'] == true && date == today && snapshot.data.documents[i]['additionalOrders'][snapshot.data.documents[i]['additionalOrders'].length-1]['verified'] == 'no') {
              _temp.addAll({
                'name': snapshot.data.documents[i]['customer'],
                'status': snapshot.data.documents[i]['status'],
                'orderNum': snapshot.data.documents[i]['orderNum'],
                'time': time2,
                'createdBy': snapshot.data.documents[i]['additionalOrders'][snapshot.data.documents[i]['additionalOrders'].length-1]['createdBy'],
                'docId': snapshot.data.documents[i].documentID,
                'made': true,
              });
              _waitingList.add(_temp);
            }
          }
          _temp = {};
        }
        waitingList = _waitingList;
        _waitingList = [];
        // waitingList = [];
        
        // debugPrint(waitingList.toString());

        return WillPopScope(
          child: Scaffold(
            // appBar: AppBar(
            //   title: Text('Trial'),
            // ),
            body: _pageOptions[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.orange[100],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              elevation: 0.0,
              items: [Icons.assignment, Icons.restaurant, Icons.assignment_late, Icons.person]
                .asMap()
                .map((key, value) => MapEntry(
                    key, 
                    BottomNavigationBarItem(
                      title: Text(''),
                      icon: (key != 2)
                      ? Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedIndex == key
                            ? Colors.orange[600]
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Icon(value),
                      )
                      : Stack(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedIndex == key
                                ? Colors.orange[600]
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Icon(value),
                          ),
                          Positioned(
                            left: 16.0,
                            child: Icon(
                              Icons.brightness_1,
                              color: Colors.red,
                              size: (waitingList.isNotEmpty) ? 9.0 : 0.0,
                            ),
                          ),
                        ],
                      ), 
                    ),
                  ),
                ).values.toList(),
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
          ),
          onWillPop: _onWillPop,
        );  
      }
    );
  }

  Future<bool> _onWillPop() async {
    return false;
  }
}