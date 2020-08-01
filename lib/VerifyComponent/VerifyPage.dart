import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class VerifyPage extends StatefulWidget {
  String restoId;

  VerifyPage({Key key, this.restoId}) : super(key: key);
  @override
  VerifyPageState createState() => VerifyPageState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class VerifyPageState extends State<VerifyPage> {

  List waitingList = [];

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: BounceScrollBehavior(),
      child: Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // actions: <Widget>[
          //   IconButton(
          //     color: Colors.black,
          //     icon: Icon(Icons.search),
          //     tooltip: 'search',
          //     onPressed: (){

          //     },  
          //   ),
          // ],
          title: Text('Verification Box', style: TextStyle(fontFamily: 'Balsamiq_Sans', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25),),
          backgroundColor: Colors.orange[100],
        ),
        body: cardList(),
      ),
    );
  }

  Widget onLoading() {
    return Center(
      child: SpinKitDualRing(
        size: 100,
        color: Colors.orange
      ),
    );
  }

  Widget cardList() {
    return StreamBuilder(
      stream: Firestore.instance.collection('orderList').where('restaurantId', isEqualTo: widget.restoId).snapshots(),
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
        
        debugPrint(waitingList.toString());

        return (waitingList.isNotEmpty)
        ? ListView.builder(
          itemCount: waitingList.length,
          itemBuilder: (context, i) => verifyCard(i, waitingList[i]),
        )
        : Center(
          child: Container(
            child: Text(
              'No Input Currently..',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    );
  }

  Widget verifyCard(i, details) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.red,
        border: Border(
          top: BorderSide(width: (i == 0) ? 0.5 : 0.0, color: Colors.grey),
          bottom: BorderSide(width: 0.5, color: Colors.grey),
        ),
      ),
      // padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: new Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
                width: MediaQuery.of(context).size.width*5/8,
                // color: Colors.grey,
                child: (details['status'][0] == 'Dine-in')
                ? Text('${details['name']} ( Table ${details['status'][1]} )', style: TextStyle(fontSize: 17),)
                : Text('${details['name']} ( ${details['status'][0]} )', style: TextStyle(fontSize: 17),)
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
                width: MediaQuery.of(context).size.width*5/8,
                // color: Colors.grey,
                child: Text('Created by: ${details['createdBy']}', style: TextStyle(fontSize: 14))
              ),
               Container(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
                width: MediaQuery.of(context).size.width*5/8,
                // color: Colors.grey,
                child: (!details['made'])
                ? Text('Order type: New Order', style: TextStyle(fontSize: 14))
                : Text('Order type: Additional Order', style: TextStyle(fontSize: 14)),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 15),
                width: MediaQuery.of(context).size.width*5/8,
                // color: Colors.grey,
                child: Text('Time: ${details['time']}', style: TextStyle(fontSize: 14))
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width*3/8,
            child: Row(
              children: <Widget>[
                Container(
                  child: new Material(
                    child: InkWell(
                      child: Container(
                        // color: Colors.green,
                        width: MediaQuery.of(context).size.width*3/16,
                        height: 125,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Accept', textAlign: TextAlign.center,),
                        ),
                      ),
                      onTap: (){
                        final snackbar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Accept. Dismiss in 5s'),
                          action: SnackBarAction(
                            textColor: Colors.yellow,
                            label: 'Accept', 
                            onPressed: (){
                              (!details['made'])
                              ? acceptData(details['docId'])
                              : acceptData2(details['docId']);
                            }
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackbar);
                      },
                    ),
                    color: Colors.transparent,
                  ),
                  color: Colors.green[400],
                ),
                Container(
                  child: new Material(
                    child: InkWell(
                      child: Container(
                        // color: Colors.green,
                        width: MediaQuery.of(context).size.width*3/16,
                        height: 125,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Trash', textAlign: TextAlign.center,),
                        ),
                      ),
                      onTap: (){
                        final snackbar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Trash. Dismiss in 5s'),
                          action: SnackBarAction(
                            textColor: Colors.yellow,
                            label: 'Trash', 
                            onPressed: (){
                              (!details['made'])
                              ? trashData(details['docId'])
                              : trashData2(details['docId']);
                            }
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackbar);
                      },
                    ),
                    color: Colors.transparent,
                  ),
                  color: Colors.red[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void acceptData(doc) async {
    CollectionReference reference = Firestore.instance.collection('orderList');
    await reference
    .document(doc)
    .updateData({
      'verified': true,
      'printed': true,
      'progress': 1,
    });
  }

  void acceptData2(doc) async {
    List addOrder;
    var reference = Firestore.instance.collection('orderList').document(doc);
    reference.get().then((snapshot) async {
      addOrder = snapshot['additionalOrders'];
      addOrder[addOrder.length-1]['verified'] = 'yes';
      // debugPrint('$addOrder');
      await reference
      .updateData({
        'additionalOrders': addOrder,
      });
    });
  }

  void trashData(doc) async {
    CollectionReference reference = Firestore.instance.collection('orderList');
    await reference
    .document(doc)
    .updateData({
      'verified': true,
      'paid': 'Trash',
      'progress': 10
    });
  }

  void trashData2(doc) async {
    List addOrder;
    var reference = Firestore.instance.collection('orderList').document(doc);
    reference.get().then((snapshot) async {
      addOrder = snapshot['additionalOrders'];
      addOrder[addOrder.length-1]['verified'] = 'trash';
      // debugPrint('$addOrder');
      await reference
      .updateData({
        'additionalOrders': addOrder,
      });
    });
  }
}