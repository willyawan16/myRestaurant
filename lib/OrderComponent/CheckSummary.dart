import 'package:flutter/material.dart';
import 'package:myapp/OrderComponent/OrderList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_counter/flutter_counter.dart';

import './AdditionalOrder.dart';

class CheckSummary extends StatefulWidget {
  Map orderList;

  CheckSummary({Key key, this.orderList}) : super(key: key);
  @override
  CheckSummaryState createState() => CheckSummaryState();
}

class CheckSummaryState extends State<CheckSummary> {
  int subtotal = 0;
  int addSubtotal = 0;
  List orders = [];
  List additionalOrders = [];
  int additionalOrderProgress = 0;
  bool change1 = false;
  bool change2 = false;
  bool change3 = false;
  bool toggleBtn;

  @override
  void initState() {
    change1 = false;
    change2 = false;
    for(int i = 0; i < widget.orderList['orders'].length; i++){
      subtotal += (int.parse(widget.orderList['orders'][i]['menuprice'])*widget.orderList['orders'][i]['quantity']);
      orders.add(widget.orderList['orders'][i]);
    }
    for(int i = 0; i < widget.orderList['additionalOrder'].length; i++){
      addSubtotal += (int.parse(widget.orderList['additionalOrder'][i]['menuprice'])*widget.orderList['additionalOrder'][i]['quantity']);
      additionalOrders.add(widget.orderList['additionalOrder'][i]);
    }
    additionalOrderProgress = widget.orderList['additionalOrderProgress'];
    if(widget.orderList['progress'] == 2) {
      toggleBtn = false;
    } else {
      toggleBtn = true;
    }
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  _updateWholeData(doc){
    if(change1){
      Firestore.instance.runTransaction((Transaction transaction) async{
        CollectionReference reference = Firestore.instance.collection('orderList');
        await reference
        .document(doc)
        .updateData({
          'orders': orders,
        });
      });
    }
    if(change2){
      if(additionalOrders.isNotEmpty){
        Firestore.instance.runTransaction((Transaction transaction) async{
          CollectionReference reference = Firestore.instance.collection('orderList');
          await reference
          .document(doc)
          .updateData({
            'additionalOrder': additionalOrders,
            'additionalOrderProgress': 0,
          });
        });
      } else {
        Firestore.instance.runTransaction((Transaction transaction) async{
          CollectionReference reference = Firestore.instance.collection('orderList');
          await reference
          .document(doc)
          .updateData({
            'additionalOrder': [],
            'additionalOrderProgress': -1,
          });
        });
      }
    }
    if(change3){
      if(additionalOrders.isNotEmpty){
        Firestore.instance.runTransaction((Transaction transaction) async{
          CollectionReference reference = Firestore.instance.collection('orderList');
          await reference
          .document(doc)
          .updateData({
            'orders': orders, 
            'progress': 0,
            'additionalOrder': additionalOrders,
            'additionalOrderProgress': 0,
          });
        });
      } else {
        Firestore.instance.runTransaction((Transaction transaction) async{
          CollectionReference reference = Firestore.instance.collection('orderList');
          await reference
          .document(doc)
          .updateData({
            'orders': orders, 
            'progress': 0,
            'additionalOrder': [],
            'additionalOrderProgress': -1,
          });
        });
      }
    }
  }

  _updatePayment(doc){
    Firestore.instance.runTransaction((Transaction transaction) async{
      CollectionReference reference = Firestore.instance.collection('orderList');
      await reference
      .document(doc)
      .updateData({
        'paid': 'Paid',
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

  @override
  Widget build(BuildContext context) {
    // debugPrint(additionalOrders.length.toString());
    // debugPrint(toggleBtn.toString());
    var _onPressed;
    if(toggleBtn) {
      _onPressed = (){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AdditionalOrder(
            docID: widget.orderList['key'], 
            additionalList: (!change3) ? additionalOrders : orders,
            callbackAdditionalList: (val){
              orders = val;
            },
            cekBool: change3,
          )),
        ).then((value) => setState((){}));
      };
    } else {
      _onPressed = null;
    }
    return Scaffold(
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
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: (){
              // _updateWholeData(widget.orderList['key']);
              // Navigator.of(context).pop();
              if(change3)
                _showVerifyDialog(context);
              else if(change1 || change2)
                _showVerifyDialog(context);
              else
                Navigator.of(context).pop();
            },
          ),
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
                  child: (toggleBtn)
                  ? FlatButton(
                    disabledColor: Colors.grey[400],
                    disabledTextColor: Colors.grey[300],
                    //splashColor: Colors.green,
                    textColor: Colors.white,
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    onPressed: _onPressed,
                    child: Text('Additional Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget body(){
    List progress = ['Waiting..', 'Serving..', 'Done!'];
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
                  (index, item) => orderDetails(context, item, index, true),
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
            (additionalOrders.isNotEmpty)
            ? Container(
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.black12,
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width*0.45,
                          child: Text('Additional Order', style: TextStyle(fontSize: 20),),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.2,
                          child: Text('(${progress[additionalOrderProgress]})', style: TextStyle(color: Colors.red),),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.29,
                          // color: Colors.red,
                          child: Text('Rp$addSubtotal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.end,),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: mapIndexed(
                        additionalOrders,
                        (index, item) => orderDetails(context, item, index, false),
                      ).toList(),
                    ),
                  ),
                ],
              ),
            )
            : Container(),
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

  Future<void> _showEditDialog(BuildContext context, details, index, orderList, bool existing) {
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
                          if(existing) {
                            subtotal = temp;
                            change1 = true;
                          } else {
                            addSubtotal = temp;
                            change2 = true;
                          }
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
                          if(existing) {
                            orders.removeAt(index);
                          } else {
                            additionalOrders.removeAt(index);
                          }
                        });
                        for(int i = 0; i < orderList.length; i++){
                          temp += (int.parse(orderList[i]['menuprice'])*orderList[i]['quantity']);
                        }
                        setState((){
                          if(existing) {
                            subtotal = temp;
                            change1 = true;
                          } else {
                            addSubtotal = temp;
                            change2 = true;
                          }
                        });
                        setState((){
                          if(orders.isEmpty){
                            change3 = true;
                            change1 = false;
                            change2 = false;
                            orders = additionalOrders;
                            subtotal = addSubtotal;
                            addSubtotal = 0;
                            additionalOrders = [];                          
                          }
                        });
                        // debugPrint('added ${sortedMenu[index]['name']}');
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

  Widget orderDetails(BuildContext context, details, int index, bool existing) {
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
                        color: Colors.green,
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
                            child: Text(details['menuname'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
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
                            child: (existing) 
                            ? (widget.orderList['progress'] == 0)
                              ? GestureDetector(
                                onTap: (){
                                  _showEditDialog(context, details, index, orders, true);
                                },
                                child: Text('Edit', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              )
                              : Text('Edit', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                            : (widget.orderList['additionalOrderProgress'] == 0)
                              ? GestureDetector(
                                onTap: (){
                                  _showEditDialog(context, details, index, additionalOrders, false);
                                },
                                child: Text('Edit', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              )
                              : Text('Edit', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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