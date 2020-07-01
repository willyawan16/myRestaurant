import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_group_sliver/flutter_group_sliver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myapp/OrderComponent/CheckOrder.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

import './MenuList.dart';

class NewOrder extends StatefulWidget {  
  String restoId;
  int count;

  NewOrder({Key key, this.restoId, this.count}) : super(key: key);
  @override
  NewOrderState createState() => NewOrderState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class NewOrderState extends State<NewOrder> with SingleTickerProviderStateMixin{
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

  final _pageController = PageController(initialPage: 0);

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
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Balsamiq_Sans',
      ),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.orange[50],
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
              if((selectedStatus == statusBuy[0] && tableNum.text !='') || selectedStatus == statusBuy[1])
              { 
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => CheckOrder(
                    name: custName.text, 
                    table: tableNum.text ,
                    orderList: _orderList,
                    wholeMenu: wholeMenu,
                    restoId: widget.restoId,
                    status: selectedStatus,
                    count: widget.count,
                    onCallbackOrderList: (val) {
                      setState(() {
                        _orderList = val;
                      });
                    },
                  )),
                );
              }
              else
              {
                _pageController.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.ease);
                toTableText();
              }
            },
            label: Text('Check Orders'),
            icon: Icon(Icons.assignment_turned_in),
            backgroundColor: Colors.green[400],
          ),
        ),
      ),
    );
  }

  Future<void> toTableText() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Table number is Empty'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Text('Please fill your table number', style: TextStyle(color: Colors.red),),
          actions: <Widget>[
            OutlineButton(
              highlightedBorderColor: Colors.orange[200],
              child: Text('Okay'),
              onPressed: (){
                Navigator.of(dialogContext).pop();
                FocusScope.of(context).requestFocus(toTableNum);
              },
            )
          ],
        );
      }
    );
  }

  Widget customerDetails(menu, tabList) {
    return new GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: PageView(
        // pageSnapping: false,
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          customerData(),
          menuList(menu),
        ],
      ),
    );
  }

  Widget customerData() {
    return CustomScrollView(
      // physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          snap: false,
          leading: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: Colors.transparent,
            ),
            child: IconButton(
              color: Colors.black,
              onPressed: (){
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          expandedHeight: 150,
          flexibleSpace: const FlexibleSpaceBar(
            centerTitle: true,
            title: Text('Create Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.orange[50],
        ),
        SliverGroupBuilder(
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //       color: Colors.grey,
            //       blurRadius: 5.0,
            //       spreadRadius: 5.0,
            //       offset: Offset(0, 0),
            //   )
            // ],
            color: Colors.orange[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(150), 
              // topRight: Radius.circular(40)
            ),
          ),
          child: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: EdgeInsets.fromLTRB(20, 150, 20, 20),
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
              Container(
                padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
                child: RaisedButton(
                  color: Colors.orange[50],
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                  elevation: 7,
                  child: Text('Proceed to Menu'),
                  onPressed: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.easeInCubic);
                  },
                ),
              ),
              SizedBox(
                height: 100,
              ),
            ]),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          // fillOverscroll: false,
          child: Container(
            // height: 400,
            color: Colors.orange[200],
            
          ),
        ),
      ],
    );
  }

  Widget menuList(menu) {
    return CustomScrollView(
      // physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: false,
          snap: false,
          leading: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: Colors.transparent,
            ),
            child: IconButton(
              color: Colors.black,
              onPressed: (){
                _pageController.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          expandedHeight: 150,
          flexibleSpace: const FlexibleSpaceBar(
            centerTitle: true,
            title: Text('Menu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.orange[50],
        ),
        SliverGroupBuilder(
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //       color: Colors.grey,
            //       blurRadius: 5.0,
            //       spreadRadius: 5.0,
            //       offset: Offset(0, 0),
            //   )
            // ],
            color: Colors.orange[200],
            borderRadius: BorderRadius.only(
              // topLeft: Radius.circular(80), 
              // topRight: Radius.circular(40),
            ),
          ),
          child: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                  child: DefaultTabController(
                    length: menu.length,
                    child: Column(
                      children: <Widget>[
                        Container(
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
                          color: Colors.orange[50],
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
        // SliverFillRemaining(
        //   hasScrollBody: false,
        //   // fillOverscroll: false,
        //   child: Container(
        //     // height: 400,
        //     color: Colors.orange[200],
            
        //   ),
        // ),
      ],
    );
  }

}