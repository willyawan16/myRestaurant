import 'package:flutter/material.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:myapp/LoginPage/auth.dart';
import './OrderComponent/Orders.dart';
import './MenuComponent/Menu.dart';
import './ProfileComponent/Profile.dart';
import './LoginPage/auth.dart';

class MyHomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  String userId;
  Map userData, restoData;

  MyHomePage({Key key, @required this.userId, this.auth, this.onSignedOut, this.userData, this.restoData}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List _pageOptions;
  Map userData, restoData;
  
  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch(e) {
      print(e);
    }
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userData = widget.userData;
    restoData = widget.restoData;
    _pageOptions = [
      Orders(restoId: widget.restoData['restaurantId'],),
      // CheckOrder(),
      Menu(restoId: widget.restoData['restaurantId'],),
      Profile(signOut: _signOut),
    ];
  }

    @override
  Widget build(BuildContext context){
    debugPrint(widget.userData.toString());
    debugPrint(widget.restoData.toString());
    return MaterialApp(
      title: 'main',
      home: Scaffold(
        // appBar: AppBar(
        //   title: Text('Trial'),
        // ),
        body: _pageOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              title: Text('Orders'),
              backgroundColor: Colors.red
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.restaurant_menu, 
                //color: Colors.deepOrange[400],
              ),
              title: Text(
                'Menu', 
                // style: TextStyle(color: Colors.deepOrange[400],)
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile'),
              backgroundColor: Colors.red
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          ),
      )
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // debugPrint('userId: ${widget.userId}');
  //   return Scaffold(
  //     body: Center(
  //       child: _pageOptions[_selectedIndex]
  //     ),
  //     bottomNavigationBar: FFNavigationBar(
  //       theme: FFNavigationBarTheme(
  //         barBackgroundColor: Colors.white,
  //         selectedItemBorderColor: Colors.transparent,
  //         selectedItemBackgroundColor: Colors.green,
  //         selectedItemIconColor: Colors.white,
  //         selectedItemLabelColor: Colors.black,
  //         showSelectedItemShadow: false,
  //         barHeight: 60,
  //       ),
  //       selectedIndex: _selectedIndex,
  //       onSelectTab: (index) {
  //         setState(() {
  //           _selectedIndex = index;
  //         });
  //       },
  //       items: [
  //         FFNavigationBarItem(
  //           iconData: Icons.assignment_turned_in,
  //           label: 'Orders',
  //           selectedBackgroundColor: Colors.green,
  //         ),
  //         FFNavigationBarItem(
  //           iconData: Icons.restaurant_menu,
  //           label: 'Menu',
  //           selectedBackgroundColor: Colors.orange,
  //         ),
  //         FFNavigationBarItem(
  //           iconData: Icons.person,
  //           label: 'Profile',
  //           selectedBackgroundColor: Colors.red,
  //         ),
  //         // FFNavigationBarItem(
  //         //   iconData: Icons.note,
  //         //   label: 'Blue',
  //         //   selectedBackgroundColor: Colors.blue,
  //         // ),
  //         // FFNavigationBarItem(
  //         //   iconData: Icons.settings,
  //         //   label: 'Red Item',
  //         //   selectedBackgroundColor: Colors.red,
  //         // ),
  //       ],
  //     ),
  //   );
  // }
}