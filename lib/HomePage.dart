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
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Trial'),
        // ),
        body: _pageOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.orange[100],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          elevation: 0.0,
          items: [Icons.assignment, Icons.restaurant, Icons.person]
            .asMap()
            .map((key, value) => MapEntry(
                key, 
                BottomNavigationBarItem(
                  title: Text(''),
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedIndex == key
                        ? Colors.orange[600]
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Icon(value),
                  ), 
                ),
              ),
            ).values.toList(),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          ),
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