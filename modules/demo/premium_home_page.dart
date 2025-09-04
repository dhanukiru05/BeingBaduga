// import 'dart:convert';

// import 'package:beingbaduga/User_Model.dart';
// import 'package:beingbaduga/modules/demo/notification_page.dart';
// import 'package:beingbaduga/modules/demo/profile_page.dart';
// import 'package:beingbaduga/utils/CPSessionManager.dart';
// import 'package:beingbaduga/utils/PreferenceUtils.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../../notification.dart';
// import '../book/book.dart';
// import '../business/business_page.dart';
// import 'matri.dart';

// class PremiumHomePage extends StatefulWidget {
//   final User user;
//   final int categoryId;
//   final String title;
//   const PremiumHomePage(
//       {super.key,
//       required this.categoryId,
//       required this.title,
//       required this.user});

//   @override
//   State<PremiumHomePage> createState() => _PremiumHomePageState();
// }

// class _PremiumHomePageState extends State<PremiumHomePage> {
//   List<Map<String, dynamic>> _members = [];
//   String _searchQuery = '';

//   final List<String> _titles = [
//     'Find Your Partner',
//     'Profile',
//     'Notifications',
//     'Payment',
//   ];
//   int _currentIndex = 0;
//   bool _isLoading = false; // Loading indicator

//   List<Widget> _pages = []; // Initialize as an empty list first

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       if (widget.categoryId == 2) {
//         _fetchMembers();
//       } else {
//         goToNextPages();
//       }
//     });
//   }

//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   Future<void> _fetchMembers() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final String apiUrl = 'https://beingbaduga.com/being_baduga/matri_get.php';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           _members = data.cast<
//               Map<String, dynamic>>(); // Convert JSON data to list of maps
//           _isLoading = false; // Set loading to false
//           // Initialize _pages only after members are fetched
//           goToNextPages();
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         throw Exception('Failed to load members');
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print('Error fetching members: $e');
//     }

//     return; // Add this line to ensure the function returns something
//   }

//   void goToNextPages() {
//     setState(() {
//       _pages = [
//         widget.categoryId == 1
//             ? BusinessPage(
//                 user: widget.user,
//               )
//             : widget.categoryId == 2
//                 ? HomePage(
//                     members: _filteredMembers,
//                     onRefresh: () async {
//                       await _fetchMembers(); // Refresh members when pulled to refresh
//                     },
//                     carouselImages: [],
//                   )
//                 : widget.categoryId == 3
//                     ? EBookPage(
//                         user: user,
//                       )
//                     : const SizedBox.shrink(), // Pass members to HomePage

//         NotificationPage(),

//       ];
//     });
//   }

//   List<Map<String, dynamic>> get _filteredMembers {
//     if (_searchQuery.isEmpty) {
//       return _members;
//     }
//     return _members.where((member) {
//       return member['full_name']!
//           .toLowerCase()
//           .contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   get user => null;

//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: theme.appBarTheme.backgroundColor,
//         elevation: 4,
//         title: Text(
//           widget.title, // Dynamic app bar title based on tab
//           style: theme.appBarTheme.titleTextStyle,
//         ),
//         centerTitle: true,
//         iconTheme: theme.appBarTheme.iconTheme,
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator()) // Show loading indicator
//           : _pages.isNotEmpty
//               ? _pages[
//                   _currentIndex] // Switch between the pages based on current index
//               : widget.categoryId == 2
//                   ? const Center(child: Text("No data available"))
//                   : _pages[_currentIndex], // If no pages
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: onTabTapped,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Notifications',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.payment),
//             label: 'Payment',
//           ),
//         ],
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white54,
//         backgroundColor: theme.primaryColor,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }
