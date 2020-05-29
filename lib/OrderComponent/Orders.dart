import 'package:flutter/material.dart';
import './OrderList.dart';
import './NewOrder.dart';

class Orders extends StatefulWidget {
  @override
  OrdersState createState() => OrdersState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScrollConfiguration(
        behavior: BounceScrollBehavior(),
        child: DefaultTabController(
          length: 2, 
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text('Orders', style: TextStyle(fontSize: 30),),
              backgroundColor: Colors.green,
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                unselectedLabelColor: Colors.white,
                labelColor: Colors.green,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                    color: Colors.green[100]),
                tabs: <Widget>[
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('Orders'),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('History'),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                OrderList(),
                Icon(Icons.attach_money),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewOrder()),
                );
              },
              label: Text('New Order'),
              icon: Icon(Icons.assignment),
              backgroundColor: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}