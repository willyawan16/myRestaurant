import 'package:flutter/material.dart';

class OrderList extends StatefulWidget {
  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {

  Widget orderCards() {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, i) => orderDetails(context, i),
    );
  }

  Widget orderDetails(BuildContext context, index) {
    var totWidth = MediaQuery.of(context).size.width - 20;
    var widthNum = totWidth * 0.3;
    var widthDetail = totWidth * 0.5;
    return Container(
      height: 100,
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
                      child: Text('Recipient ${(index+1).toString()}', style: TextStyle(fontSize: 20)),
                    ),
                    Container(
                      child: Text('Date: '),
                    ),
                    Container(
                      child: Text('Paid: -')
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: orderCards(),
      backgroundColor: Colors.green[100],
    );
  }
}