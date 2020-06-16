import 'package:flutter/material.dart';

import './CheckSummary.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

class OrderList extends StatefulWidget {
  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {

  Widget orderCards(List order) {
    return ListView.builder(
      itemCount: order.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, i) => orderDetails(context, i, order[i]),
    );
  }

  Future<void> _progressUpdate(details) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Order Progress?'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: 100,
            child: Column(
              children: <Widget>[
                Text('Waiting.. -> Serving.. -> Done!'),
                SizedBox(
                  height: 20,
                ),
                (details['progress'] == 0)
                ? Text('Update to Serving', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),)
                : Text('Update to Done!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 10),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Container(
              child: OutlineButton(
                onPressed: (){
                  details['progress']++;
                  // debugPrint(details['progress'].toString());
                  updateProgress(details['key'], details['progress'], 0);
                  Navigator.of(context).pop();
                },
                child: Text('Yes'),
              ),
            )
          ],
        );
      }
    );
  }

  Future<void> _progress2Update(details) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Additional Order Progress?'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: 100,
            child: Column(
              children: <Widget>[
                Text('Waiting.. -> Serving.. -> Done!'),
                SizedBox(
                  height: 20,
                ),
                (details['additionalOrderProgress'] == 0)
                ? Text('Update to Serving', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),)
                : Text('Update to Done!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 10),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Container(
              child: OutlineButton(
                onPressed: (){
                  details['additionalOrderProgress']++;
                  // debugPrint(details['progress'].toString());
                  updateProgress(details['key'], details['additionalOrderProgress'], 1);
                  Navigator.of(context).pop();
                },
                child: Text('Yes'),
              ),
            )
          ],
        );
      }
    );
  }

  Future<void> _finalProgressUpdate(details) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update to "Done!"?'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: 100,
            child: Column(
              children: <Widget>[
                Text('Waiting.. -> Serving.. -> Done!'),
                SizedBox(
                  height: 20,
                ),
                (details['progress'] == 0)
                ? Text('Update to Serving', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),)
                : Text('Update to Done!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 10),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Container(
              child: OutlineButton(
                onPressed: (){
                  details['progress']++;
                  updateProgress(details['key'], details['progress'], 0);
                  details['additionalOrderProgress']++;
                  debugPrint(details['additionalOrderProgress'].toString());
                  updateProgress(details['key'], details['additionalOrderProgress'], 1);
                  Navigator.of(context).pop();
                },
                child: Text('Yes'),
              ),
            )
          ],
        );
      }
    );
  }

  Future<void> _proceedPayment(Map details) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Payment..'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: 30,
            child: Column(
              children: <Widget>[
                Text('NB: Proceed to payment'),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 10),
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Container(
              child: OutlineButton(
                onPressed: (){
                  // payment page
                  Navigator.of(dialogContext).pop();
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => CheckSummary(orderList: details,)),
                  );
                },
                child: Text('Yes'),
              ),
            )
          ],
        );
      }
    );
  }

  void updateProgress(doc, nextState, int number) async {
    if(number == 0) {
      Firestore.instance.runTransaction((Transaction transaction) async{
        CollectionReference reference = Firestore.instance.collection('orderList');
        await reference
        .document(doc)
        .updateData({
          'progress': nextState
        });
      });
    } else if (number == 1) {
      Firestore.instance.runTransaction((Transaction transaction) async{
        CollectionReference reference = Firestore.instance.collection('orderList');
        await reference
        .document(doc)
        .updateData({
          'additionalOrderProgress': nextState
        });
      });
    }
  }

  Widget orderDetails(BuildContext context, index, details) {
    var totWidth = MediaQuery.of(context).size.width - 20;
    var widthNum = totWidth * 0.3;
    var widthDetail = totWidth * 0.5;
    var widthLeft = totWidth - widthNum - widthDetail -10;
    var totHeight = 150.0;
    List progress = ['Waiting..', 'Serving..', 'Done!'];
    // debugPrint('[$index]: ${progress[progressCount]}');
    return GestureDetector(
      onDoubleTap: (){
        if(details['progress'] != 2) {
          if(details['progress'] == 1 && details['additionalOrderProgress'] == 0) {
            _progress2Update(details);
          } else if(details['progress'] == 1 && details['additionalOrderProgress'] == 1) {
            _finalProgressUpdate(details);
          } else {
            _progressUpdate(details);
          }
        } else if (details['progress'] == 2){
          _proceedPayment(details);
        }
      },
      onTap: (){
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => CheckSummary(orderList: details,)),
        );
      },
      child: Container(
        height: totHeight,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Row(
            children: <Widget>[
              Container(
                // height: 100,
                width: widthNum,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                ),
                child: Center(
                  child: ListTile(
                    title: Text(
                      'Order',
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Text(
                      (index+1).toString(), 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: widthDetail,
                // color: Colors.indigo,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(details['customer'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        child: Text('Status: ${details['status'][0]}'),
                      ),
                      Container(
                        child: Text('Time: ${details['time']}'),
                      ),
                      Container(
                        child: RichText(
                          text: TextSpan(
                            text: 'Progress: ',
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${progress[details['progress']]}', style: (details['progress'] == 2) ? TextStyle(fontWeight: FontWeight.w800, color: Colors.green) : TextStyle(fontWeight: FontWeight.w800, color: Colors.red))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: (details['progress'] == 2)
                        ? RichText(
                          text: TextSpan(
                            text: 'Paid: ',
                            style: DefaultTextStyle.of(context).style, 
                            children: <TextSpan>[
                               TextSpan(text: '${details['paid']}', style: (details['paid'] == 'Paid') ? TextStyle(fontWeight: FontWeight.w800, color: Colors.green) : TextStyle(fontWeight: FontWeight.w800, color: Colors.red))
                            ],
                          ),
                        )
                        : Text(''),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0,10,5,10),
                // color: Colors.yellow,
                width: widthLeft,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: totHeight * 0.6-10,
                      // color: Colors.amber,
                      child: (details['status'][1] != 0)
                      ? ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 70),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green,
                          ),
                          child: Center(
                            child: Text(
                              'Table ${details['status'][1]}', 
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,shadows: [
                                  Shadow( // bottomLeft
                                    offset: Offset(-0.5, -0.5),
                                    color: Colors.white
                                  ),
                                  Shadow( // bottomRight
                                    offset: Offset(0.5, -0.5),
                                    color: Colors.white
                                  ),
                                  Shadow( // topRight
                                    offset: Offset(0.5, 0.5),
                                    color: Colors.white
                                  ),
                                  Shadow( // topLeft
                                    offset: Offset(-0.5, 0.5),
                                    color: Colors.white
                                  ),
                                ]
                              ), 
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                      : Container(),
                    ),
                    // Container(
                    //   height: totHeight * 0.2-10,

                    //   // color: Colors.pink,
                    //   child: Text('Timer'),
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget body(List orderList, bool check){
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: Colors.green[100],
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2.0,
                      spreadRadius: 2.0,
                      offset: Offset(1.0, 1.0),
                  )
                ],
              ),
              padding: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width,
              // color: Colors.red,
              child: Text(
                'Today: ${DateFormat('EEE, MMM d, yyy').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            (orderList.isNotEmpty)
            ? Expanded(
              child: ListView.builder(
                itemCount: orderList.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, i) => orderDetails(context, i, orderList[i]),
              ),
            )
            : Container(
              padding: EdgeInsets.fromLTRB(40,50,40,0),
              child: (!check)
              ? Text('Make your First Order Today', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
              : Text('Make New Order Again', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            ),
          ],
        ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance.collection('orderList').snapshots(),
        builder: (context, snapshot) {
          List orderList = [];
          Map _temp = {};
          var date, time;
          bool check = false;
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
              'progress': snapshot.data.documents[i]['progress'],
              'additionalOrder': snapshot.data.documents[i]['additionalOrder'],
              'additionalOrderProgress': snapshot.data.documents[i]['additionalOrderProgress'],
              'paid': snapshot.data.documents[i]['paid'],
              'status': snapshot.data.documents[i]['status'],
              'key': snapshot.data.documents[i].documentID,
            });
            var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
            if(_temp['paid'] != 'Paid' && _temp['date'] == today)
              orderList.add(_temp);
            else if(_temp['date'] == today)
              check = true;
            _temp = {};
          }
          orderList.sort((a, b) {
            return a['time'].compareTo(b['time']);
          });
          return body(orderList, check);
        },
      ),
    );
  }
}