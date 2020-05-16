import 'package:flutter/material.dart';

class CheckOrder extends StatefulWidget {
  String name, table, status;
  List orderList, wholeMenu;

  CheckOrder({Key key, this.name, this.table, this.orderList, this.wholeMenu, this.status}) : super(key: key);
  @override
  CheckOrderState createState() => CheckOrderState();
}

class CheckOrderState extends State<CheckOrder> {
  List<int> tempTotal =[];
  int subtotal = 0;  

  @override
  void initState() {
    for(int i = 0; i < widget.orderList.length; i++){
      subtotal += int.parse(widget.orderList[i][4]);
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    if(widget.name == '') {
      widget.name = 'Customer';
    }
    if(widget.orderList.isNotEmpty) {
      for (var i = 0; i < widget.orderList.length; i++) {
        debugPrint('masuk(${widget.orderList.length}): ' + widget.orderList[i].toString());
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
                        child: Text('Rpxxx.xxx', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign:TextAlign.right),
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
            // Expanded(
            //   child: Container(
            //     color: Colors.red,
            //     child: ListView.builder(
            //       itemCount: widget.orderList.length,
            //       itemBuilder: (context, i) => orderDetails(context, widget.orderList[i]),
            //     ),
            //   ),
            // ),
            Container(
              child: Column(
                children: widget.orderList.map<Widget>(
                  (item) => orderDetails(context, item),
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
                          child: Text('Rp${subtotal}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign:TextAlign.right),
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

  Widget orderDetails(BuildContext context, List details) {
    double totWidth = MediaQuery.of(context).size.width;
    double iconWidth = 30.0;
    double priceWidth = 80.0;
    double detailsWidth = totWidth - iconWidth - priceWidth -15;
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
                        height: 30,
                        //width: 290,
                        child: Text(details[3], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      ),
                      Container(
                        height: 30,
                        child:GestureDetector(
                          onTap: (){

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
}