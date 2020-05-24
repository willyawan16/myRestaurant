import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_counter/flutter_counter.dart';
import 'package:myapp/OrderComponent/OrderList.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class CheckOrder extends StatefulWidget {
  String name, table, status;
  List orderList, wholeMenu;
  
  final Function(List) onCallbackOrderList;

  CheckOrder({Key key, this.name, this.table, this.orderList, this.wholeMenu, this.status, this.onCallbackOrderList}) : super(key: key);
  @override
  CheckOrderState createState() => CheckOrderState();
}

class CheckOrderState extends State<CheckOrder> {
  List<int> tempTotal =[];
  int subtotal = 0;  
  List newList;
  // StreamController<List> _stream;


  @override
  void initState() {
    // _stream = new StreamController<List>();
    for(int i = 0; i < widget.orderList.length; i++){
      subtotal += (int.parse(widget.orderList[i][4])*widget.orderList[i][2]);
    }
    // _stream.add(widget.orderList);
    super.initState();
  }

  Future<void> _showEditDialog(BuildContext context, details, index, orderList) {
    // debugPrint(quantityFood.text);
    // debugPrint(details[3]);
    TextEditingController descOrder = TextEditingController(text: details[1]);
    int quantityFood = details[2];
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
                title: Text('Edit ${details[3]}'),
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
                              minValue: 1,
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
                    child: OutlineButton(
                      onPressed: () {
                        int temp = 0;
                        setState(() {
                          details[2] = quantityFood;
                          details[1] = descOrder.text;
                        });
                        for(int i = 0; i < orderList.length; i++){
                          temp += (int.parse(orderList[i][4])*orderList[i][2]);
                        }
                        setState((){
                          subtotal = temp;
                        });
                        widget.onCallbackOrderList(orderList);
                        // debugPrint('added ${sortedMenu[index]['name']}');
                        Navigator.of(context).pop();
                        
                      }, 
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
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
  
  @override
  Widget build(BuildContext context) {
    if(widget.name == '') {
      widget.name = 'Customer';
    }
    if(widget.orderList.isNotEmpty) {
      debugPrint('------------------------------------------------------');
      debugPrint('Received order list: ');
      for (var i = 0; i < widget.orderList.length; i++) {
        debugPrint('received($i): ' + widget.orderList[i].toString());
      }
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          title: Text('Check Orders'),
          flexibleSpace: FlexibleSpaceBar(
            title: Row(
              children: <Widget>[
                Text(widget.name, style: TextStyle(fontSize: 17)),
                SizedBox(
                  width: 5,
                ),
                Text('|'),
                SizedBox(
                  width: 5,
                ),
                (widget.status == 'Dine-in') 
                ? Text('Table ${widget.table}', style: TextStyle(fontSize: 17))
                : Text('Take-away', style: TextStyle(fontSize: 17)),
              ],
            ),
          ),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: (){
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
                        child: Text('Rp$subtotal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign:TextAlign.right),
                      )
                    ],
                  ),
                ),
                Container(
                  // color: Colors.purpleAccent,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    //splashColor: Colors.green,
                    textColor: Colors.white,
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    onPressed: (){

                    }, 
                    child: Text('Submit Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
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
                  widget.orderList,
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

  Widget orderDetails(BuildContext context, List details, int index) {
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
                      child: Text('x${details[2]}', style: TextStyle(fontWeight: FontWeight.bold),),
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
                            child: Text(details[3], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          ),
                          (details[1] != '') 
                          ? Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(details[1]),
                          )
                          : Container(
                            padding: EdgeInsets.only(bottom: 10),
                          ),
                          Container(
                            height: 30,
                            child:GestureDetector(
                              onTap: (){
                                _showEditDialog(context, details, index, widget.orderList);
                              },
                              child: Text('Edit', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ),
                          ),               
                        ],
                      ),
                    ),
                  ),
                  // Price
                  Container(
                    width: priceWidth,
                    child: Text((int.parse(details[4])*details[2]).toString(), style: TextStyle(fontSize: 18), textAlign: TextAlign.right,),
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