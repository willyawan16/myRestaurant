import 'package:flutter/material.dart';

class CheckSummary extends StatefulWidget {
  Map orderList;

  CheckSummary({Key key, this.orderList}) : super(key: key);
  @override
  CheckSummaryState createState() => CheckSummaryState();
}

class CheckSummaryState extends State<CheckSummary> {
  int subtotal = 0;

  @override
  void initState() {
    for(int i = 0; i < widget.orderList['orders'].length; i++){
      subtotal += (int.parse(widget.orderList['orders'][i]['menuprice'])*widget.orderList['orders'][i]['quantity']);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      // _addData();
                      // int count = 0;
                      // Navigator.popUntil(context, (route) {
                      //     return count++ == 2;
                      // });
                    }, 
                    child: Text('Additional Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
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
                  widget.orderList['orders'],
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
                            child: (widget.orderList['progress'] == 0)
                            ? GestureDetector(
                              onTap: (){
                                // _showEditDialog(context, details, index, widget.orderList);
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