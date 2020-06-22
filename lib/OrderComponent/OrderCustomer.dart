import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_group_sliver/flutter_group_sliver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myapp/OrderComponent/CheckOrder.dart';

import './MenuList.dart';

class OrderCustomer extends StatefulWidget {  
  String restoId;

  OrderCustomer({Key key, this.restoId}) : super(key: key);
  @override
  OrderCustomerState createState() => OrderCustomerState();
}

class OrderCustomerState extends State<OrderCustomer> with SingleTickerProviderStateMixin{
  TextEditingController custName, tableNum;
  int currentIndex;
  String selectedStatus;
  List wholeMenu = [];
  List sortedMenu = [];
  List<Tab> menu = [];
  List _orderList = [];
  int recIndex;
  List<String> statusBuy = ['Dine-in', 'Take-away'];

  TabController _tabController;
  FocusNode toTableNum;

  @override
  void initState() {
    super.initState();
    custName = TextEditingController(text: '');
    tableNum = TextEditingController(text: ''); 
    toTableNum = new FocusNode();
    selectedStatus = 'Dine-in';
    if(menu.isNotEmpty)
      _tabController = new TabController(vsync: this, length: menu.length);
  }

  @override
  void dispose() {
    if(menu.isNotEmpty)
      _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if(_orderList.length != 0){
      debugPrint('Order list: ');
      for (var i = 0; i < _orderList.length; i++) {
        debugPrint('[$i]: ${_orderList[i].toString()}');
      }
    } else {
      debugPrint('Order list is empty!');
    }
    return Scaffold(
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
          List<Tab> menu = tabList.map((tab) => Tab(text: tab)).toList();
          //debugPrint(tes);
          return customerDetails(menu, tabList);
        },
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: (_orderList.isNotEmpty)
        ? 1.0
        : 0.0,
        duration: Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: (){
            ((selectedStatus == statusBuy[0] && tableNum.text !='') || selectedStatus == statusBuy[1])
            ? Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => CheckOrder(
                  name: custName.text, 
                  table: tableNum.text ,
                  orderList: _orderList,
                  wholeMenu: wholeMenu,
                  restoId: widget.restoId,
                  status: selectedStatus,
                  onCallbackOrderList: (val) {
                    setState(() {
                      _orderList = val;
                    });
                  },
                )),
              )
            : FocusScope.of(context).requestFocus(toTableNum);
          },
          label: Text('Check Orders'),
          icon: Icon(Icons.assignment),
          backgroundColor: Colors.green[400],
        ),
      ),
    );
  }

  Widget customerDetails(menu, tabList) {
    return new GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Customer Input', style: TextStyle(color: Colors.black)),
            ),
            backgroundColor: Colors.white,
          ),
          SliverGroupBuilder(
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
            child: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: TextField(            
                    controller: custName,        
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'Customer Name',
                      hintText: 'Customer',
                      labelStyle: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                    ),
                    underline: Container(
                      height: 2,
                      color: Colors.grey,
                    ),
                    items: statusBuy.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                    }).toList(),
                    onChanged: (String str) {
                      setState(() {
                        selectedStatus = str;
                      });
                    },
                  ),
                ),
                (selectedStatus == 'Dine-in') 
                ? Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 250, 20),
                  child: TextField(      
                    focusNode: toTableNum,     
                    controller: tableNum,
                    keyboardType: TextInputType.number,       
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'Table',
                      //hintText: 'Name of New Menu',
                      labelStyle: TextStyle(fontSize: 17),
                    ),
                  ),
                )
                : Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                ),
                SizedBox(
                  height: 1,
                  child: const DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.green[100],
                  child: Text('Pick Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                ),
                Container(
                  child: DefaultTabController(
                    length: menu.length,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: TabBar(
                            isScrollable: true,
                            labelStyle: TextStyle(fontSize: 20),
                            unselectedLabelStyle: TextStyle(fontSize: 15),
                            controller: _tabController,
                            tabs: menu,
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height/4*3,
                          child: TabBarView(
                            children: menu.map<Widget>((Tab tab) {
                              return MenuList(
                                whoCall: 'OrderCustomer',
                                category:tab.text, 
                                wholeMenu: wholeMenu,
                                orderList: _orderList,
                                onAddMenu: (val) {
                                  setState(() {
                                    Map temp = {};
                                    temp.addAll(val);
                                    _orderList.add(temp);
                                  });
                                },
                                getIndex: (val) {
                                  setState(() {
                                    recIndex = val;
                                  });
                                },
                                onUpdateMenu: (val) {
                                  setState(() {
                                    _orderList[recIndex] = val;
                                  });
                                }
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  
}