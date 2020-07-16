import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/OrderComponent/CheckSummaryForWorker.dart';
import './LoginPageForWorker/LoginPageForWorker.dart';
import 'OrderComponent/NewOrderByWorker.dart';

class RootPageForWorker extends StatefulWidget {
  @override
  RootPageForWorkerState createState() => RootPageForWorkerState();
}

enum AuthStatus{
  notSignedIn,
  signedIn
}

class RootPageForWorkerState extends State<RootPageForWorker> {

  AuthStatus authStatus = AuthStatus.notSignedIn;

  String _userId, _email, restoDocId, restoId, tableNum, name;
  int count;
  var _userData;
  var _restoData; 

  initState() {
    super.initState();
    count = 0;
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
        return new LoginPageForWorker(
          onSignedIn: _signedIn,
          restoDocId: (val) {
            restoDocId = val;
          },
          restoId: (val) {
            restoId = val;
          },
          tableNum: (val) {
            tableNum = val;
          },
          name: (val) {
            name = val;
          },
        );
      case AuthStatus.signedIn:
        return StreamBuilder(
          stream: Firestore.instance.collection('orderList').where('restaurantId', isEqualTo: restoId).snapshots(),
          builder: (context, snapshot) {
            List orderList = [];
            Map currentOrder = {};
            Map _temp = {};
            var date, time;
            bool check = false, newOrder = true;
            int _count = 0;
            if(!snapshot.hasData) return const Text('Loading');
            for(int i = 0; i < snapshot.data.documents.length; i++) {
              Timestamp t = snapshot.data.documents[i]['date'];
              DateTime d = t.toDate();
              date = DateFormat('yyyy-MM-dd').format(d);
              time = DateFormat('h:mm a').format(d);
              _temp.addAll({
                'customer': snapshot.data.documents[i]['customer'],
                'date': date,
                'time': time,
                'orders': snapshot.data.documents[i]['orders'],
                'orderNum': snapshot.data.documents[i]['orderNum'],
                'progress': snapshot.data.documents[i]['progress'],
                'paid': snapshot.data.documents[i]['paid'],
                'status': snapshot.data.documents[i]['status'],
                'key': snapshot.data.documents[i].documentID,
              });
              var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
              if(_temp['paid'] != 'Paid' && _temp['date'] == today && _temp['progress'] != 10) { 
                orderList.add(_temp);
                _count++;
              } else if(_temp['date'] == today) {
                check = true;
                _count++;
              }
              _temp = {};
            }
            orderList.sort((a, b) {
              return a['time'].compareTo(b['time']);
            });
            count = _count;
            _count = 0;
            // debugPrint(count.toString());
            for(int i = 0; i < orderList.length; i++) {
              debugPrint(orderList[i].toString());
              if(tableNum == orderList[i]['status'][1]) {
                newOrder = false;
                currentOrder = orderList[i];
                break;
              }
            }
            
            if(newOrder) {
              return NewOrderByWorker(
                restoId: restoId,
                count: count,
                tableNum: tableNum,
                name: name,
                // onSignedOut: _signedOut,
              );
            } else {
              return CheckSummaryForWorker(
                restoId: restoId,
                orderList: currentOrder,
              );
            }
          },
        );
    }
  }
}