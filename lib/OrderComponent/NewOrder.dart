import 'package:flutter/material.dart';

import './OrderCustomer.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';

class NewOrder extends StatefulWidget {
  String restoId;

  NewOrder({Key key, this.restoId}) : super(key: key);
  @override
  NewOrderState createState() => NewOrderState();
}

class NewOrderState extends State<NewOrder> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), 
          tooltip: 'back',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('New Order'),
      ),
      body: OrderCustomer(restoId: widget.restoId),

    );
  }
}