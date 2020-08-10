import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import './CheckSummary.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

class OrderList extends StatefulWidget {
  String restoId;
  Function(int) count;
  Function(List) inUseTable;

  OrderList({Key key, this.restoId, this.count, this.inUseTable}) : super(key: key);

  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {
  String delete;
  int count;
  List inUseTable = [];

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
          title: Text('Mengudate Progress?'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: 110,
            child: Column(
              children: <Widget>[
                Text('Sedang Berjalan -> Siap!'),
                SizedBox(
                  height: 20,
                ),
                Text('Update ke Siap!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),),
                Text('NB: Order Tidak dapat diubah lagi', style: TextStyle(fontSize: 14))
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

  Future<void> _proceedPayment(Map details) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Pembayaran..'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: 30,
            child: Column(
              children: <Widget>[
                Text('NB: Lanjut ke pembayaran'),
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
                  'batal',
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
                  Navigator.of(context, rootNavigator: true).push( 
                    MaterialPageRoute(builder: (context) => CheckSummary(orderList: details)),
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

  Future<void> _deleteOrder(doc) {
    delete = '';
    var _onPressed = (){
      deleteOrder(doc);
      Navigator.of(context).pop();
    };
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext addcontext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: AlertDialog(
                
                title: Text('Buang Order?'),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  height: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Ingin buang?')
                      // Container(
                      //   child: Text('Type "delete" to delete'),
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // TextField(
                      //   onChanged: (val){
                      //     delete = val;
                      //     debugPrint('$delete');
                          
                      //   },
                      //   decoration: InputDecoration(
                      //     hintText: 'Type "Delete"',
                      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  Container(
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      }, 
                      child: Text(
                        'batal',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      color: Colors.red,
                      onPressed: _onPressed,
                      child: Text('Buang', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    ).then((value) => setState((){}));
  }

  void deleteOrder(doc) async {
    CollectionReference reference = Firestore.instance.collection('orderList');
    await reference
    .document(doc)
    .updateData({
      'progress': 10,
      'paid': 'Dibuang',
    });
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
    // debugPrint('>>>$details');
    var totWidth = MediaQuery.of(context).size.width - 20;
    var widthNum = totWidth * 0.3;
    var widthDetail = totWidth * 0.5;
    var widthLeft = totWidth - widthNum - widthDetail -10;
    var totHeight = 150.0;
    List progress = ['Belum Print', 'Sedang berjalan..', 'Siap!'];
    // debugPrint('[$index]: ${progress[progressCount]}');
    return GestureDetector(
      onLongPress: (){
        _deleteOrder(details['key']);
      },
      onDoubleTap: (){
        if(details['progress'] == 0) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Ingat PRINT!'), backgroundColor: Colors.orange,));
        } else if(details['progress'] != 2) {
          _progressUpdate(details);
        } else if (details['progress'] == 2){
          _proceedPayment(details);
        }
      },
      onTap: (){
        debugPrint('>>>$details');
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => CheckSummary(orderList: details, restoId: widget.restoId)),
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
                  color: Colors.orange[300],
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
                      (details['orderNum']).toString(), 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 20, 
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
                        child: Text('Waktu: ${details['time']}'),
                      ),
                      Container(
                        child: Text('Dibuat oleh: ${details['createdBy']}'),
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
                            text: 'Bayar: ',
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
                            color: Colors.orange[300],
                          ),
                          child: Center(
                            child: Text(
                              'Meja ${details['status'][1]}', 
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,
                                shadows: [
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
      backgroundColor: Colors.orange[50],
      body: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: Colors.orange[50],
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

  Widget onLoading() {
    return Center(
      child: SpinKitDualRing(
        size: 100,
        color: Colors.orange
      ),
    );
  }

  Widget build(BuildContext context) {
    debugPrint('Get Id: ${widget.restoId}');
    int _count = 0;
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance.collection('orderList').where('restaurantId', isEqualTo: widget.restoId).snapshots(),
        builder: (context, snapshot) {
          List orderList = [];
          Map _temp = {};
          var date, time;
          bool check = false;
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
              'orderNum': snapshot.data.documents[i]['orderNum'],
              'progress': snapshot.data.documents[i]['progress'],
              'paid': snapshot.data.documents[i]['paid'],
              'status': snapshot.data.documents[i]['status'],
              'verified': snapshot.data.documents[i]['verified'],
              'printed':  snapshot.data.documents[i]['printed'],
              'additionalOrders': snapshot.data.documents[i]['additionalOrders'],
              'createdBy': snapshot.data.documents[i]['createdBy'],
              'key': snapshot.data.documents[i].documentID,
            });
            var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
            if(_temp['paid'] != 'Sudah Bayar' && _temp['date'] == today && _temp['progress'] != 10 && _temp['verified'] == true) { 
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
          debugPrint(count.toString());
          widget.count(count);
          List _inUseTable = [];
          for(int i = 0; i < orderList.length; i++) {
            if(orderList[i]['status'][0] == 'Dine-in') {
              _inUseTable.add(orderList[i]['status'][1]);
            }
          }
          inUseTable = _inUseTable;
          _inUseTable = [];
          widget.inUseTable(inUseTable);
          // debugPrint('$orderList');
          return body(orderList, check);
        },
      ),
    );
  }
}