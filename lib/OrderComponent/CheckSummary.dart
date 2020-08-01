import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/OrderComponent/AdditionalOrdersHistory.dart';
import 'package:myapp/OrderComponent/OrderList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_counter/flutter_counter.dart';

import './AdditionalOrder.dart';

class CheckSummary extends StatefulWidget {
  Map orderList;
  String restoId;

  CheckSummary({Key key, this.orderList, this.restoId}) : super(key: key);
  @override
  CheckSummaryState createState() => CheckSummaryState();
}

class CheckSummaryState extends State<CheckSummary> with SingleTickerProviderStateMixin{
  int subtotal = 0;
  int firstSubtotal = 0;
  int addSubtotal = 0;
  // Map orderData = {};
  List orders = [], additionalOrders = [];
  bool changes = false;
  bool toggleBtn;

  AnimationController _animationController;
  Animation _animation;

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    
    
    if(widget.orderList['progress'] != 2) {
      toggleBtn = true;
    } else {
      toggleBtn = false;
    }

    _animationController = AnimationController(vsync:this,duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation =  Tween(begin: 2.0,end: 15.0).animate(_animationController)..addListener((){
      setState(() {
        
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _updateWholeData(doc){
    if(changes){
      Firestore.instance.runTransaction((Transaction transaction) async{
        CollectionReference reference = Firestore.instance.collection('orderList');
        await reference
        .document(doc)
        .updateData({
          'orders': orders,
          'progress': 0,
        });
      });
    }
  }

  _updatePrint(doc){
    Firestore.instance.runTransaction((Transaction transaction) async{
      CollectionReference reference = Firestore.instance.collection('orderList');
      await reference
      .document(doc)
      .updateData({
        'printed': true,
        'progress': 1,
      });
    });
  }

  _updatePayment(doc){
    Firestore.instance.runTransaction((Transaction transaction) async{
      CollectionReference reference = Firestore.instance.collection('orderList');
      await reference
      .document(doc)
      .updateData({
        'paid': 'Paid',
        'income': subtotal,
      });
    });
  }

  Future<void> _showVerifyDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext){
        return AlertDialog(
          title: Text('Overwrite changes?'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            child: Text('Save new changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
            FlatButton(
              onPressed: (){
                // int count = 0;
                // Navigator.popUntil(context, (route) {
                //   return count++ == 1;
                // });
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Discard',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ),
            OutlineButton(
              onPressed: (){
                _updateWholeData(widget.orderList['key']);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      }

    );
  }

  Future<void> _takeAwayDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          title: Text('Take-away?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 15),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FlatButton(
              child: Text('No', style: TextStyle(fontSize: 15),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AdditionalOrder(
                    docID: widget.orderList['key'], 
                    restoId: widget.restoId,
                    orderList: orders,
                    orderData: widget.orderList,
                    takeaway: false,
                  )),
                ).then((value) => setState((){}));
              },
            ),
            FlatButton(
              child: Text('Yes', style: TextStyle(fontSize: 15),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AdditionalOrder(
                    docID: widget.orderList['key'], 
                    restoId: widget.restoId,
                    orderList: orders,
                    orderData: widget.orderList,
                    takeaway: true,
                  )),
                ).then((value) => setState((){}));
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('${widget.orderList}');
    // debugPrint(additionalOrders.length.toString());
    // debugPrint(toggleBtn.toString());
    // debugPrint('${widget.orderList['orders']}');
    var _onPressed;
    if(toggleBtn) {
      _onPressed = (){
        _takeAwayDialog();
      };
    } else {
      _onPressed = null;
    }
    return StreamBuilder(
      stream: Firestore.instance.collection('orderList').document('${widget.orderList['key']}').snapshots(),
      builder: (context, snapshot) {
        var _temp = {};
        var orderData;
        var _orders = [], _snapshotOrder = [], _snapshotAddOrder = [];
        var _subtotal1 = 0, _subtotal2 = 0;
        List tempOrders = [];
        if(!snapshot.hasData) return const Text('Loading...');
        _snapshotOrder = snapshot.data['orders'];
        _snapshotAddOrder = snapshot.data['additionalOrders'];

        for(int i = 0; i < _snapshotOrder.length; i++){
          _subtotal1 += (int.parse(_snapshotOrder[i]['menuprice'])*_snapshotOrder[i]['quantity']);
          tempOrders.add(_snapshotOrder[i]);
          tempOrders[tempOrders.length-1]['takeaway'] = 0;
        }
        _orders = tempOrders;
        tempOrders = [];
        firstSubtotal = _subtotal1;

        for(int i = 0; i < _snapshotAddOrder.length; i++) {
          
          if(_snapshotAddOrder[i]['verified'] == 'yes') {
            _subtotal2 += _snapshotAddOrder[i]['subtotal'];
            var currentList = _snapshotAddOrder[i]['orders'];

            for(int j = 0; j < currentList.length; j++) {
              var indexResult = _orders.indexWhere((item) => item['key'] == currentList[j]['key']);
              if(indexResult != -1) {
                var quantity = _orders[indexResult]['quantity'];
                quantity += currentList[j]['quantity'];
                _orders[indexResult]['quantity'] = quantity;
                quantity = 0;

                // _orders[indexResult]['takeaway'] = 0;
                if(_snapshotAddOrder[i]['takeaway'] == true) {
                  _orders[indexResult]['takeaway'] += currentList[j]['quantity'];
                }

              } else {
                _orders.add(currentList[j]);
                _orders[_orders.length-1]['takeaway'] = 0;
                if(_snapshotAddOrder[i]['takeaway'] == true) {
                  _orders[_orders.length-1]['takeaway'] += currentList[j]['quantity'];
                }
              }
            }
          }
        }
        subtotal = _subtotal1 + _subtotal2;
        orders = _orders;
        _subtotal1 = 0;
        _subtotal2 = 0;

        // debugPrint('$orders');
        // debugPrint('---> $subtotal');


        return WillPopScope(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: AppBar(
                title: Text('Order Overview'),
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    children: <Widget>[
                      Text(widget.orderList['customer'], style: TextStyle(fontSize: 17)),
                      SizedBox(
                        width: 5,
                      ),
                      Text('|'),
                      SizedBox(
                        width: 5,
                      ),
                      (widget.orderList['status'][0] == 'Dine-in') 
                      ? Text('Table ${widget.orderList['status'][1]}', style: TextStyle(fontSize: 17))
                      : Text('Take-away', style: TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
                backgroundColor: Colors.orange,
                leading: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: (){
                    // _updateWholeData(widget.orderList['key']);
                    // Navigator.of(context).pop();
                    if(changes)
                      _showVerifyDialog(context);
                    else
                      Navigator.of(context).pop();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.history), 
                    onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AdditionalOrdersHistory(
                          additionalOrders: widget.orderList['additionalOrders'], 
                          firstSubtotal: firstSubtotal,
                          printAccess: true,
                        )),
                      );
                    }, 
                    tooltip: 'Additional Order History',
                  ),
                ],
              ),
            ), 
            body: body(),
            bottomNavigationBar: Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                color: Colors.white,
                boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                        spreadRadius: 5.0,
                        offset: Offset(2.0, 2.0),
                    )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Container(
                  // color: Colors.amber,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 0, bottom: 10,),
                        child: Row(
                          children: <Widget>[
                            Container(
                              // color: Colors.pink,
                              width: MediaQuery.of(context).size.width/2 - 10,
                              child: Text('Total', style: TextStyle(fontSize: 20),),
                            ),
                            Container(
                              // color: Colors.blue,
                              width: MediaQuery.of(context).size.width/2 - 10,
                              child: Text('Rp${subtotal + addSubtotal}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign:TextAlign.right),
                            )
                          ],
                        ),
                      ),
                      Container(
                        // color: Colors.purpleAccent,
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: (widget.orderList['printed'] != true)
                        ? FlatButton(
                          child: Text('Print Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),),
                          onPressed: () {
                            _updatePrint(widget.orderList['key']);
                            Navigator.of(context).pop();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          color: Colors.red,
                        )
                        : (toggleBtn)
                          // ? new Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //   children: <Widget>[
                          //     Container(
                          //       // width: 100,
                          //       // height: 100,
                          //       child: FlatButton(
                                  // disabledColor: Colors.grey[400],
                                  // disabledTextColor: Colors.grey[300],
                          //         //splashColor: Colors.green,
                          //         textColor: Colors.white,
                          //         color: Colors.green,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(20)
                          //         ),
                          //         onPressed: _onPressedSubmit,
                          //         child: Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                          //       ),
                          //       decoration: (changes)
                          //       ? BoxDecoration(
                          //         shape: BoxShape.rectangle,
                          //         borderRadius: BorderRadius.circular(20),
                          //         color: Colors.green,
                          //         boxShadow: [BoxShadow(
                          //           color: Colors.lightGreen[300],
                          //           blurRadius: _animation.value,
                          //           spreadRadius: _animation.value
                          //         )]
                          //       )
                          //       : null
                          //       ,
                          //     ),
                          //     FlatButton(
                          //       disabledColor: Colors.grey[400],
                          //       disabledTextColor: Colors.grey[300],
                          //       //splashColor: Colors.green,
                          //       textColor: Colors.white,
                          //       color: Colors.orange,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(20)
                          //       ),
                          //       onPressed: _onPressed,
                          //       child: Text('Add Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                          //     ),
                          //   ],
                          // )
                          ? FlatButton(
                            disabledColor: Colors.grey[400],
                            disabledTextColor: Colors.grey[300],
                            //splashColor: Colors.green,
                            textColor: Colors.white,
                            color: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            ),
                            onPressed: _onPressed,
                            child: Text('Add Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                          )
                          : FlatButton(
                            disabledColor: Colors.grey[400],
                            disabledTextColor: Colors.grey[300],
                            //splashColor: Colors.green,
                            textColor: Colors.white,
                            color: Colors.red[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            ),
                            onPressed: (){
                              _updatePayment(widget.orderList['key']);
                              Navigator.of(context).pop();
                            },
                            child: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ), 
          onWillPop: () async {
            return false;
          },
        );
      }
    );
  }

  Widget body(){
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[300],
              height: 50,
              padding: EdgeInsets.all(8),
              child: Text(
                'Order Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ), 
              ),
            ),
            Container(
              child: Column(
                children: mapIndexed(
                  orders,
                  (index, item) => orderDetails(context, item, index),
                ).toList(),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              // color: Colors.greenAccent,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/2 - 10,
                          child: Text('Subtotal', style: TextStyle(fontSize: 20),),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width/2 - 10,
                          child: Text('Rp$subtotal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign:TextAlign.right),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, 
    E Function(int index, T item) f
  ) sync* {
    var index = 0;

    for (final item in items) {
      yield f(index, item);
      index = index + 1;
    }
  }

  Future<void> _showEditDialog(BuildContext context, details, index, orderList) {
    // debugPrint(quantityFood.text);
    // debugPrint(details[3]);
    // debugPrint(index.toString());
    TextEditingController descOrder = TextEditingController(text: details['description']);
    int quantityFood = details['quantity'];
    // FocusNode quantityFoodNode = new FocusNode();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: new AlertDialog(
                title: Text('Edit ${details['menuname']}'),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  height: 200,
                  // color: Colors.grey,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: TextField(
                            controller: descOrder,
                            maxLength: 60,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Additional Details',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Counter(
                              initialValue: quantityFood,
                              minValue: 0,
                              maxValue: 10,
                              step: 1,
                              decimalPlaces: 0,
                              buttonSize: 30,
                              color: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  quantityFood = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: (quantityFood > 0)
                    ? OutlineButton(
                      onPressed: () {
                        int temp = 0;
                        setState(() {
                          details['quantity'] = quantityFood;
                          details['description'] = descOrder.text;
                        });
                        for(int i = 0; i < orderList.length; i++){
                          temp += (int.parse(orderList[i]['menuprice'])*orderList[i]['quantity']);
                        }
                        setState((){
                          subtotal = temp;
                          changes = true;
                        });
                        // debugPrint('added ${sortedMenu[index]['name']}');
                        Navigator.of(context).pop();
                        
                      }, 
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    )
                    : OutlineButton(
                      onPressed: (){
                        int temp = 0;
                        setState(() {
                            orders.removeAt(index);
                        });
                        for(int i = 0; i < orderList.length; i++){
                          temp += (int.parse(orderList[i]['menuprice'])*orderList[i]['quantity']);
                        }
                        setState((){
                          subtotal = temp;
                          changes = true;
                        });
                        // setState((){
                        //   if(orders.isEmpty){
                        //     change3 = true;
                        //     change1 = false;
                        //     change2 = false;
                        //     orders = additionalOrders;
                        //     subtotal = addSubtotal;
                        //     addSubtotal = 0;
                        //     additionalOrders = [];                          
                        //   }
                        // });
                        // // debugPrint('added ${sortedMenu[index]['name']}');
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                    )
                  ),
                ],
              ),
            );
          }
        );
      }
    ).then((value) => setState((){}));
  } 

  Widget orderDetails(BuildContext context, details, int index) {
    double totWidth = MediaQuery.of(context).size.width;
    double iconWidth = 30.0;
    double priceWidth = 80.0;
    double detailsWidth = totWidth - iconWidth - priceWidth -15;
    return new StatefulBuilder(
      builder: (context, setState) {
        return Container(
          //height: 80,
          width: totWidth,
          padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
          // color: Colors.lightBlue[100],
          child: new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  // Icon
                  Container(
                    //padding: EdgeInsets.all(2),
                    height: 30,
                    width: iconWidth,
                    child: Center(
                      child: Text('x${details['quantity']}', style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    decoration: BoxDecoration(
                      // color: Colors.lightGreen,
                      border: Border.all(
                        color: Colors.orange,
                        width: 3
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                  ),
                  // Details
                  Container(
                    // color: Colors.lightBlueAccent,
                    width: detailsWidth,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 20,
                            //width: 290,
                            child: (details['takeaway'] > 0)
                            ? Text('${details['menuname']} (${details['takeaway']} T-A)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                            : Text('${details['menuname']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          ),
                          (details['description'] != '') 
                          ? Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(details['description']),
                          )
                          : Container(
                            padding: EdgeInsets.only(bottom: 10),
                          ),
                          Container(
                            height: 30,
                            child: Text('Edit', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                            // child: (widget.orderList['progress'] == 0)
                            // ? GestureDetector(
                            //   onTap: (){
                            //     _showEditDialog(context, details, index, orders);
                            //   },
                            //   child: Text('Edit', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            // )
                            // : Text('Edit', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                            // child: GestureDetector(
                            //   onTap: (){
                            //     _showEditDialog(context, details, index, orders);
                            //   },
                            //   child: Text('Edit', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            // ),
                          ),               
                        ],
                      ),
                    ),
                  ),
                  // Price
                  Container(
                    width: priceWidth,
                    child: Text((int.parse(details['menuprice'])*details['quantity']).toString(), style: TextStyle(fontSize: 18), textAlign: TextAlign.right,),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Divider(thickness: 1,),
              ),
            ],
          ),
        );
      }
    );
  }
}