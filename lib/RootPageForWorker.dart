import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_group_sliver/flutter_group_sliver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'OrderComponent/ForWorker/NewOrderByWorker.dart';
import './LoginPageForWorker/LoginPageForWorker.dart';
import 'OrderComponent/ForWorker/CheckSummaryForWorker.dart';

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

  // Widget onLoading() {
  //   return Center(
  //     child: Container(
  //       height: 50,
  //       width: 50,
  //       child: Card(
  //         elevation: 10,
  //         child: SpinKitCubeGrid(
  //           size: 30,
  //           color: Colors.red,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget onLoading() {
    return CustomScrollView(
      // physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          snap: false,
          leading: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: Colors.transparent,
            ),
            child: IconButton(
              color: Colors.black,
              onPressed: (){
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          expandedHeight: 150,
          flexibleSpace: const FlexibleSpaceBar(
            centerTitle: true,
            title: Text('Create Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.orange[50],
        ),
        SliverGroupBuilder(
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //       color: Colors.grey,
            //       blurRadius: 5.0,
            //       spreadRadius: 5.0,
            //       offset: Offset(0, 0),
            //   )
            // ],
            color: Colors.orange[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(150), 
              // topRight: Radius.circular(40)
            ),
          ),
          child: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: EdgeInsets.fromLTRB(20, 150, 20, 20),
                child: Container(
                  width: 200,
                  height: 200,
                  child: SpinKitChasingDots(
                    size: 100,
                    color: Colors.orange
                  ),
                ),
                
              ),
              
            ]),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          // fillOverscroll: false,
          child: Container(
            // height: 400,
            color: Colors.orange[200],
            
          ),
        ),
      ],
    );
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
          tableNum: (val) {
            tableNum = val;
          },
          restoId: (val) {
            restoId = val;
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
            if(!snapshot.hasData) return onLoading();
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
                'additionalOrders': snapshot.data.documents[i]['additionalOrders'],
                'printed': snapshot.data.documents[i]['printed'],
                'verified': snapshot.data.documents[i]['verified'],
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
            // debugPrint('$currentOrder');
            
            if(newOrder) {
              return NewOrderByWorker(
                restoId: restoId,
                count: count,
                name: name,
                tableNum: tableNum,
                restoDocId: restoDocId,
                // onSignedOut: _signedOut,
              );
            } else {
              return CheckSummaryForWorker(
                restoId: restoId,
                orderList: currentOrder,
                tableNum: tableNum,
                name: name,
              );
            }
          },
        );
    }
  }
}