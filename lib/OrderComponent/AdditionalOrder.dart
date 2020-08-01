import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:myapp/OrderComponent/CheckAdditionalOrder.dart';

import './MenuList.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class AdditionalOrder extends StatefulWidget {
  String docID, restoId;
  List orderList;
  bool cekBool, takeaway;
  Map orderData;
  Function(List) callbackAdditionalList;
  Function(int) updateSubtotal;
  Function(bool) changes;

  AdditionalOrder({Key key, this.docID, this.orderList, this.callbackAdditionalList, this.cekBool, this.restoId, this.updateSubtotal, this.changes, this.orderData, this.takeaway}) : super(key: key);
  @override
  AdditionalOrderState createState() => AdditionalOrderState();
}

class AdditionalOrderState extends State<AdditionalOrder> with SingleTickerProviderStateMixin{
  List wholeMenu = [];
  List _orderList = [];
  List<Tab> menu = [];
  int recIndex;
  int subtotal = 0;
  bool changed = false;
  List additionalOrders = [];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    // for(int i = 0; i < widget.orderList.length; i++){
    //   _orderList.add(widget.orderList[i]);
    // }
    // if(_orderList.isNotEmpty){
    //   for(int i = 0; i < _orderList.length; i++){
    //     subtotal += (int.parse(_orderList[i]['menuprice'])*_orderList[i]['quantity']);
    //   }
    // }

    if(menu.isNotEmpty)
      _tabController = new TabController(vsync: this, length: menu.length);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.docID);
    if(_orderList.length != 0){
      debugPrint('Order list: ');
      for (var i = 0; i < _orderList.length; i++) {
        debugPrint('[$i]: ${_orderList[i].toString()}');
      }
    } else {
      debugPrint('Additional Order list is empty!');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Order'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('menuList').where('restaurantId', isEqualTo: widget.restoId).snapshots(),
        builder: (context, snapshot) {
          List<String> tabList = [];
          if(!snapshot.hasData) return const SpinKitDualRing(color: Colors.red, size: 50.0,);
          // debugPrint(tabList.toString());
          List _wholeMenu = [];
          Map _temp = {};
          for(int i = 0; i < snapshot.data.documents.length; i++){
            _temp.addAll({
              'name': snapshot.data.documents[i]['name'],
              'description': snapshot.data.documents[i]['description'],
              'price': snapshot.data.documents[i]['price'],
              'category': snapshot.data.documents[i]['category'],
              'picture': snapshot.data.documents[i]['picture'],
              'key': snapshot.data.documents[i].documentID,
            });
            _wholeMenu.add(_temp);
            _temp = {};
          }
          wholeMenu = _wholeMenu;
          for(int i = 0; i < wholeMenu.length; i++){
            if(tabList.isEmpty)
            {
              tabList.add(wholeMenu[i]['category']);
            }
            else
            {
              bool needChange = true;
              for(int j = 0; j < tabList.length; j++){
                if(wholeMenu[i]['category'] == tabList[j]){
                  needChange = false;
                }
              }
              if(needChange == true){
                  tabList.add(wholeMenu[i]['category']);
              } 
              needChange = true;
            }
          }
          tabList.sort();
          //debugPrint(tabList.toString());
          // debugPrint(tabList[1].toString());
          menu = tabList.map((tab) => Tab(text: tab)).toList();
          return menuList(menu);
        },
      ),
      bottomNavigationBar: Container(
        height: 80,
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
                // Container(
                //   padding: EdgeInsets.only(top: 0, bottom: 10,),
                //   child: Row(
                //     children: <Widget>[
                //       Container(
                //         // color: Colors.pink,
                //         width: MediaQuery.of(context).size.width/2 - 10,
                //         child: Text('Subtotal', style: TextStyle(fontSize: 20),),
                //       ),
                //       Container(
                //         // color: Colors.blue,
                //         width: MediaQuery.of(context).size.width/2 - 10,
                //         child: Text('Rp$subtotal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign:TextAlign.right),
                //       )
                //     ],
                //   ),
                // ),
                Container(
                  // color: Colors.purpleAccent,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    //splashColor: Colors.green,
                    disabledColor: Colors.grey[400],
                    disabledTextColor: Colors.grey[300],
                    textColor: Colors.white,
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: (additionalOrders.isNotEmpty)
                    ? (){
                      // _updateData(widget.docID);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CheckAdditionalOrder(
                          orderData: widget.orderData,
                          orderList: additionalOrders,
                          onCallbackOrderList: (val) {
                            additionalOrders = val;
                          },
                          subtotal: (val) {
                            subtotal = val;
                          },
                          takeaway: widget.takeaway,
                        )),
                      ).then((value) => setState(() {}));
                      // debugPrint(_orderList.toString());
                      // widget.callbackAdditionalList(additionalOrders);
                      // widget.updateSubtotal(subtotal);
                      // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Make sure to SUBMIT order again')));
                      // Navigator.of(context).pop();
                      // Navigator.of(context).pop();
                      // widget.changes(true);
                    }
                    : null,
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

  Widget menuList(List<Tab> menu) {
    return Container(
      color: Colors.orange[200],
      child: DefaultTabController(
        length: menu.length, 
        child: Column(
          children: <Widget>[
            Container(
              height: 60,
              child: TabBar(
                indicatorColor: Colors.lime,
                indicator: new BubbleTabIndicator(
                  indicatorHeight: 40.0,
                  indicatorColor: Colors.orangeAccent[400],
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                ),
                controller: _tabController,
                isScrollable: true,
                labelStyle: TextStyle(fontSize: 20, fontFamily: 'Balsamiq_Sans'),
                unselectedLabelStyle: TextStyle(fontFamily: 'Balsamiq_Sans', fontSize: 15,),
                unselectedLabelColor: Colors.grey,
                tabs: menu,
              ), 
            ),
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.6,
              child: TabBarView(
                children: menu.map<Widget>((Tab tab) {
                  return MenuList(
                    whoCall: 'AdditionalOrder',
                    category: tab.text, 
                    wholeMenu: wholeMenu,
                    orderList: additionalOrders,
                    onAddMenu: (val) {
                      setState(() {
                        Map temp = {};
                        temp.addAll(val);
                        additionalOrders.add(temp);
                      });
                    },
                    getIndex: (val) {
                      setState(() {
                        recIndex = val;
                      });
                    },
                    onUpdateMenu: (val) {
                      setState(() {
                        additionalOrders[recIndex] = val;
                      });
                    },
                    updateSubtotal: (val){
                      setState(() {
                        subtotal += val;
                      });
                    },
                    changed: (val){
                      setState(() {
                        changed = val;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}