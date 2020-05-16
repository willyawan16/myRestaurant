// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import './Home.dart';
// import './Menu.dart';
// import './NewMenu.dart';

// void main() {
//   FlutterError.onError = (FlutterErrorDetails details) {
//     FlutterError.dumpErrorToConsole(details);
//     if (kReleaseMode)
//       exit(1);
//   };
//   runApp(MyApp());
//   //runApp(NewMenu());
// }

// class MyApp extends StatefulWidget {
//   @override
//   State<MyApp> createState() {
//     return MyAppState();
//   }
// }
  
// class MyAppState extends State<MyApp> {
//   int _currentIndex = 0;
  // final _pageOptions = [
  //   Home(),
  //   Menu(),
  // ];
//   @override
//   Widget build(BuildContext context){
//     return MaterialApp(
//       title: 'main',
//       home: Scaffold(
//         // appBar: AppBar(
//         //   title: Text('Trial'),
//         // ),
//         body: _pageOptions[_currentIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.assignment),
//               title: Text('Orders'),
//               backgroundColor: Colors.red
//             ),

//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.restaurant_menu, 
//                 //color: Colors.deepOrange[400],
//               ),
//               title: Text(
//                 'Menu', 
//                 // style: TextStyle(color: Colors.deepOrange[400],)
//               ),
//             ),
//           ],
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           ),
//       )
//     );
//   }
// }

