import 'package:flutter/material.dart';
import './OrderList.dart';
import './HistoryList.dart';
import './NewOrder.dart';
import '../MenuComponent/NewMenu.dart';

class Orders extends StatefulWidget {
  String restoId;

  Orders({Key key, this.restoId}) : super(key: key);
  @override
  OrdersState createState() => OrdersState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class OrdersState extends State<Orders> {
  int count;
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: BounceScrollBehavior(),
      child: DefaultTabController(
        length: 2, 
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Text('Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),),
            backgroundColor: Colors.orange[100],
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: Colors.white,
              labelColor: Colors.orange,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)),
                  color: Colors.orange[50]),
              tabs: <Widget>[
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Orders', style: TextStyle(fontFamily: 'Balsamiq_Sans'),),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('History', style: TextStyle(fontFamily: 'Balsamiq_Sans')),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OrderList(
                restoId: widget.restoId, 
                count: (val){
                  count = val;
                },
              ),
              HistoryList(restoId: widget.restoId),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewOrder(restoId: widget.restoId, count: count)),
              );
            },
            label: Text('New Order'),
            icon: Icon(Icons.assignment),
            backgroundColor: Colors.orangeAccent[400],
          ),
        ),
      ),
    );
  }
}