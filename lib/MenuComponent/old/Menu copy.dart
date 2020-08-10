
// import 'package:flutter/material.dart';
// import './MenuList.dart';
// import './NewMenu.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';

// class Menu extends StatefulWidget {
//   String restoId;

//   Menu({Key key, this.restoId}) : super(key: key);
//   @override
//   MenuState createState() => new MenuState();
// }

// class BounceScrollBehavior extends ScrollBehavior {
//   @override
//   getScrollPhysics(_) => const BouncingScrollPhysics();
// }

// class MenuState extends State<Menu> with SingleTickerProviderStateMixin {
//   // final List<Tab> menu = <Tab>[
//   //   Tab(text: 'Rice'),
//   //   Tab(text: 'Drinks'),
//   // ];
//   List<Tab> menu = [];

//   TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     if(menu.isNotEmpty)
//       _tabController = new TabController(vsync: this, length: menu.length);
//   }

//   @override
//   void dispose() {
//     if(menu.isNotEmpty)
//       _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: StreamBuilder(
//         stream: Firestore.instance.collection('menuList').snapshots(),
//         builder: (context, snapshot){
//           List<String> tabList = [];
//           if(!snapshot.hasData) return const SpinKitDualRing(color: Colors.red, size: 50.0,);
//           // debugPrint(tabList.toString());
//           for(int i = 0; i < snapshot.data.documents.length; i++){
//             if(snapshot.data.documents[i]['restaurantId'] == widget.restoId) {
//               if(tabList.isEmpty)
//               {
//                 tabList.add(snapshot.data.documents[i]['category']);
//               }
//               else
//               {
//                 bool needChange = true;
//                 for(int j = 0; j < tabList.length; j++){
//                   if(snapshot.data.documents[i]['category'] == tabList[j]){
//                     needChange = false;
//                   }
//                 }
//                 if(needChange == true){
//                     tabList.add(snapshot.data.documents[i]['category']);
//                 } 
//                 needChange = true;
//               }
//             }
//           }
//           tabList.sort();
//           //debugPrint(tabList.toString());
//           // debugPrint(tabList[1].toString());
//           List<Tab> menu = tabList.map((tab) => Tab(text: tab)).toList();
//           // debugPrint('ok');
//           return ScrollConfiguration(
//             behavior: BounceScrollBehavior(), 
//             child: DefaultTabController(
//               length: menu.length,
//               child: Scaffold(
//                 appBar: AppBar(
//                   actions: <Widget>[
//                     IconButton(
//                       icon: Icon(Icons.search),
//                       tooltip: 'search',
//                       onPressed: (){

//                       },  
//                     ),
//                   ],
//                   bottom: new TabBar(
//                     indicatorColor: Colors.lime,
//                     controller: _tabController,
//                     isScrollable: true,
//                     labelStyle: TextStyle(fontSize: 20),
//                     unselectedLabelStyle: TextStyle(fontSize: 15),
//                     tabs: menu,
//                   ),
//                   title: const Text('Menu', style: TextStyle(fontSize: 30),),
//                   backgroundColor: Colors.deepOrange[400],
//                 ),
//                 body: (!(tabList.length == 0)) ?
//                   TabBarView(
//                     controller: _tabController,
//                     children: menu.map((Tab tab) {
//                       return new MenuList(category: tab.text,);
//                     }).toList(),
//                   )
//                   :
//                   _ifBlank()
//                 ,
//                 floatingActionButton: FloatingActionButton.extended(
//                   onPressed: (){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => NewMenu(restoId: widget.restoId)),
//                     );
//                   },
//                   label: Text('New Menu'),
//                   icon: Icon(Icons.create),
//                   backgroundColor: Colors.orangeAccent[400],
//                 ),
//               ),
//             ),
//           );
//         }
//       ),
//     );
//   }

//   Widget _ifBlank(){
//     return Scaffold(
//       backgroundColor: Colors.orangeAccent[100],
//     );
//   }

// }