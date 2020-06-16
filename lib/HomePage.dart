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

  MyHomePage({Key key, @required this.userId, this.auth, this.onSignedOut}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List _pageOptions;
  
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
    _pageOptions = [
      Orders(),
      // CheckOrder(),
      Menu(),
      Profile(signOut: _signOut),
    ];
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.userId);
    return Scaffold(
      body: Center(
        child: _pageOptions[_selectedIndex]
      ),
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBorderColor: Colors.transparent,
          selectedItemBackgroundColor: Colors.green,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
          showSelectedItemShadow: false,
          barHeight: 60,
        ),
        selectedIndex: _selectedIndex,
        onSelectTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.assignment_turned_in,
            label: 'Orders',
            selectedBackgroundColor: Colors.green,
          ),
          FFNavigationBarItem(
            iconData: Icons.restaurant_menu,
            label: 'Menu',
            selectedBackgroundColor: Colors.orange,
          ),
          FFNavigationBarItem(
            iconData: Icons.person,
            label: 'Profile',
            selectedBackgroundColor: Colors.red,
          ),
          // FFNavigationBarItem(
          //   iconData: Icons.note,
          //   label: 'Blue',
          //   selectedBackgroundColor: Colors.blue,
          // ),
          // FFNavigationBarItem(
          //   iconData: Icons.settings,
          //   label: 'Red Item',
          //   selectedBackgroundColor: Colors.red,
          // ),
        ],
      ),
    );
  }
}