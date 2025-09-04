// import 'package:beingbaduga/User_Model.dart';
// import 'package:beingbaduga/modules/business/business_page.dart';
// import 'package:beingbaduga/modules/matermoney/matermoney_page.dart';
// import 'package:beingbaduga/modules/music/music_page.dart';
// import 'package:flutter/material.dart';

// class MainContent extends StatefulWidget {
//     late final User user; // Add this line to accept User

//   @override
//   _MainContentState createState() => _MainContentState();
// }

// class _MainContentState extends State<MainContent> {
//   int _selectedIndex = 0;

//   static List<Widget> _pages = <Widget>[
//     MusicPage(),
//     MatermoneyPage(),
//     BusinessPage(user: widget.user),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.music_note),
//             label: 'Music',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.people),
//             label: 'MaterMoney',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.business),
//             label: 'Business',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//       ),
//     );
//   }w
// }
