import 'package:flutter/material.dart';
import './NewMenu.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './MenuList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'GlobalState.dart';

class Menu extends StatefulWidget {
  String restoId;

  Menu({Key key, this.restoId}) : super(key: key);
  @override
  MenuState createState() => MenuState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  // final List<Tab> menu = <Tab>[
  //   Tab(text: 'Rice'),
  //   Tab(text: 'Drinks'),
  // ];
  List<Tab> menu = [];
  Icon actionIcon = new Icon(Icons.search, color: Colors.black,);
  // final TextEditingController _searchQuery = new TextEditingController();
  // String _searchQuery = '';
  Widget appBarTitle = new Text("Menu", style: TextStyle(fontFamily: 'Balsamiq_Sans', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),);
  // bool isSearching = false;

  TabController _tabController;

  @override
  void initState() {
    // isSearching = false;
    super.initState();
    if(menu.isNotEmpty)
      _tabController = new TabController(vsync: this, length: menu.length);
  }

  @override
  void dispose() {
    if(menu.isNotEmpty)
      _tabController.dispose();
    super.dispose();
  }

  Widget onLoading() {
    return Center(
      child: SpinKitDualRing(
        size: 100,
        color: Colors.orange
      ),
    );
  }

  // void _handleSearchStart() {
  //   setState(() {
  //     isSearching = true;
  //   });
  // }

  // void _handleSearchEnd() {
  //   setState(() {
  //     this.actionIcon = new Icon(Icons.search, color: Colors.black,);
  //     this.appBarTitle =
  //     new Text("Menu", style: TextStyle(fontFamily: 'Balsamiq_Sans', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),);
  //     isSearching = false;
  //     // _searchQuery.clear();
  //     _searchQuery = '';
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // debugPrint(_searchQuery.text);
    return StreamBuilder(
      stream: Firestore.instance.collection('menuList').snapshots(),
      builder: (context, snapshot){
        List<String> tabList = [];
        if(!snapshot.hasData) return onLoading();
        // debugPrint(tabList.toString());
        for(int i = 0; i < snapshot.data.documents.length; i++){
          if(snapshot.data.documents[i]['restaurantId'] == widget.restoId) {
            if(tabList.isEmpty)
            {
              tabList.add(snapshot.data.documents[i]['category']);
            }
            else
            {
              bool needChange = true;
              for(int j = 0; j < tabList.length; j++){
                if(snapshot.data.documents[i]['category'] == tabList[j]){
                  needChange = false;
                }
              }
              if(needChange == true){
                  tabList.add(snapshot.data.documents[i]['category']);
              } 
              needChange = true;
            }
          }
        }
        tabList.sort();
        //debugPrint(tabList.toString());
        // debugPrint(tabList[1].toString());
        List<Tab> menu = tabList.map((tab) => Tab(text: tab)).toList();
        return ScrollConfiguration(
          behavior: BounceScrollBehavior(),
          child: DefaultTabController(
            length: menu.length,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  // IconButton(
                  //   // color: Colors.black,
                  //   icon: actionIcon,
                  //   tooltip: 'search',
                  //   onPressed: (){
                  //     setState(() {
                  //       if(this.actionIcon.icon == Icons.search) 
                  //       {
                  //         this.actionIcon = new Icon(Icons.close, color: Colors.black);
                  //         this.appBarTitle = new TextField(
                  //           // controller: _searchQuery,
                  //           onChanged: (val) {
                  //             _searchQuery = val;
                  //             // store.set('val', _searchQuery);
                  //           },
                  //           style: new TextStyle(
                  //             color: Colors.black,
                  //           ),
                  //           decoration: new InputDecoration(
                  //               prefixIcon: new Icon(Icons.search, color: Colors.black),
                  //               hintText: "Search...",
                  //               hintStyle: new TextStyle(color: Colors.black)
                  //           ),
                  //         );
                  //         _handleSearchStart();
                  //       }
                  //       else 
                  //       {
                  //         _handleSearchEnd();
                  //       }
                  //     });
                  //   },  
                  // ),
                ],
                bottom: new TabBar(
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
                // title: const Text('Menu', style: TextStyle(fontFamily: 'Balsamiq_Sans', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),),
                title: appBarTitle,
                backgroundColor: Colors.orange[100],
              ),
              body: (!(tabList.length == 0)) ?
                TabBarView(
                  controller: _tabController,
                  children: menu.map((Tab tab) {
                    return new MenuList(
                      category: tab.text, 
                      restoId: widget.restoId, 
                      // isSearching: isSearching, 
                      // query: _searchQuery.text,
                    );
                  }).toList(),
                )
                :
                _ifBlank()
              ,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewMenu(restoId: widget.restoId)),
                  );
                },
                label: Text('Menu Baru'),
                icon: Icon(Icons.create),
                backgroundColor: Colors.orangeAccent[400],
              ),  
            ),
          ),
        );
      },
    );
  }

  Widget _ifBlank(){
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Text('Menu is Empty..', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
      backgroundColor: Colors.orangeAccent[100],
    );
  }
}