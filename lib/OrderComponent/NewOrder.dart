import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_group_sliver/flutter_group_sliver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myapp/OrderComponent/CheckOrder.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

import './MenuList.dart';

class NewOrder extends StatefulWidget {  
  String restoId, restoDocId;
  int count;
  List inUseTable;

  NewOrder({Key key, this.restoId, this.count, this.restoDocId, this.inUseTable}) : super(key: key);
  @override
  NewOrderState createState() => NewOrderState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class NewOrderState extends State<NewOrder> with SingleTickerProviderStateMixin{
  TextEditingController custName, tableNum;
  int tableNumPick;
  int currentIndex;
  String selectedStatus;
  List wholeMenu = [];
  List sortedMenu = [];
  List<Tab> menu = [];
  List _orderList = [], tableList = [];
  int recIndex, gridScale;
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
  
  Widget loadingScreen() {
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
            title: Text('Buat Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                child: Container(
                  width: 200,
                  height: 200,
                  child: SpinKitChasingDots(
                    size: 100,
                    color: Colors.orange
                  ),
                ),
                
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
  @override
  Widget build(BuildContext context) {
    debugPrint('${widget.inUseTable}');
    if(_orderList.length != 0){
      debugPrint('Order list: ');
      for (var i = 0; i < _orderList.length; i++) {
        debugPrint('[$i]: ${_orderList[i].toString()}');
      }
    } else {
      debugPrint('Order list is empty!');
    }
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.orange[50],
        body: StreamBuilder(
          stream: Firestore.instance.collection('menuList').where('restaurantId', isEqualTo: widget.restoId).snapshots(),
          builder: (context, snapshot) {
            List<String> tabList = [];
            List _tableList = [];
            if(!snapshot.hasData) return loadingScreen();
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

            var restaurantDocReference = Firestore.instance.collection('restaurant').document('${widget.restoDocId}');
            restaurantDocReference.get().then((snapshot) {
              // debugPrint('${snapshot['table']}')
              gridScale = snapshot['table']['gridScale'];
              for(int i = 0; i < snapshot['table']['tableList'].length; i++) {
                _tableList.add(snapshot['table']['tableList'][i]);
              }
              tableList = _tableList;
              _tableList = [];
            });

            // debugPrint('$tableList');
            return customerDetails(menu, tabList);
          },
        ),
        floatingActionButton: AnimatedOpacity(
          opacity: (_orderList.isNotEmpty)
          ? 1.0
          : 0.0,
          duration: Duration(milliseconds: 500),
          child: FloatingActionButton.extended(
            onPressed: (_orderList.isNotEmpty)
            ? (){
              if((selectedStatus == statusBuy[0] && tableNumPick != null) || selectedStatus == statusBuy[1])
              { 
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => CheckOrder(
                    name: custName.text, 
                    // table: tableNum.text ,
                    table: tableList[tableNumPick],
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
            }
            : null,
            label: Text('Check Orders'),
            icon: Icon(Icons.assignment_turned_in),
            backgroundColor: Colors.green[400],
          ),
        ),
      ), 
      onWillPop: _onWillPop,
    );
  }
  Future<bool> _onWillPop() async {
    return false;
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
          content: Text('Please pick table number', style: TextStyle(color: Colors.red),),
          actions: <Widget>[
            OutlineButton(
              highlightedBorderColor: Colors.orange[200],
              child: Text('Okay'),
              onPressed: (){
                Navigator.of(dialogContext).pop();
                // FocusScope.of(context).requestFocus(toTableNum);
              },
            )
          ],
        );
      }
    );
  }

  Future<void> _pickTableNum() {

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.orange[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          title: Text('Pick Table Number'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: 500,
                width: 1000,
                // color: Colors.orange,
                child: Container(
                  child: GridView.count(
                    crossAxisCount: gridScale,
                    children: mapIndexed(
                      tableList,
                      (index, item) => table(item, index, dialogContext),
                    ).toList(),
                  ),
                ),
              );
            }
          ),
        );
      }
    ).then((value) => setState(() {}));
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

  Widget table(content, int index, dialogContext) {
    // bool shakeEnabled = false;
    return Container(
      child: new Material(
        child: InkWell(
          splashColor: Colors.grey,
          // onTap: () {
            // tableNumPick = index;
            // Navigator.of(dialogContext).pop();
          // },
          onTap: (widget.inUseTable.indexOf(content) == -1)
          ? () {
            tableNumPick = index;
            Navigator.of(dialogContext).pop();
          }
          : null,
          child: Container(
            height: double.infinity,
            child: Center(
              child: Text(content.toString(), style: TextStyle(fontSize: 24.0),),
            ),
          )
        ),
        color: Colors.transparent,
      ),
      decoration: BoxDecoration(
        // color: (tableNumPick == index) ? Colors.orange : Colors.transparent,
        color: (widget.inUseTable.indexOf(content) == -1) 
        ? (tableNumPick == index) ? Colors.orange : Colors.transparent
        : Colors.black45,
        border: Border.all(color: Colors.black, width: 0.1),
      ),
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
              icon: Icon(Icons.close),
            ),
          ),
          expandedHeight: 150,
          flexibleSpace: const FlexibleSpaceBar(
            centerTitle: true,
            title: Text('Buat Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                    labelText: 'Nama Customer',
                    hintText: 'Tidak harus',
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
                      tableNumPick = null;
                    });
                  },
                ),
              ),
              (selectedStatus == 'Dine-in') 
              // ? Container(
              //   padding: EdgeInsets.fromLTRB(20, 0, 250, 20),
              //   child: TextField(      
              //     focusNode: toTableNum,     
              //     controller: tableNum,
              //     keyboardType: TextInputType.number,       
              //     decoration: InputDecoration(
              //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //       labelText: 'Table',
              //       //hintText: 'Name of New Menu',
              //       labelStyle: TextStyle(fontSize: 17),
              //     ),
              //   ),
              // )
              ? Container(
                // width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child:  new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      (tableNumPick != null)
                      ? 'No Meja: ${tableList[tableNumPick]}' 
                      : 'No Meja: Belum Pilih' , 
                      style: TextStyle(fontSize: 17),
                    ),
                    OutlineButton(
                      highlightedBorderColor: Colors.orange,
                      splashColor: Colors.orange[50],
                      child: Text('Pilih'),
                      onPressed: () {
                        _pickTableNum();
                      },
                    ),
                  ],
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
                  child: Text('Lanjut ke Menu'),
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