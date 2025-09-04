// import 'package:beingbaduga/User_Model.dart';
// import 'package:beingbaduga/modules/matermoney/matri_upload.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'member_details.dart';
// import 'notification_page.dart';
// import 'profile_page.dart';

// class MainMatrimonyPage extends StatefulWidget {
//   late final User user; // Accept the User object

//   @override
//   _MainMatrimonyPageState createState() => _MainMatrimonyPageState();
// }

// class _MainMatrimonyPageState extends State<MainMatrimonyPage> {
//   final List<Map<String, dynamic>> _members = [
//     // Example data that includes "age" but no "dob".
//     {
//       "id": 1,
//       "user_id": 1,
//       "full_name": "bev",
//       "profile_photo_url":
//           "https://res.cloudinary.com/dordpmvpm/image/upload/v1725134787/a0yrhyfd9y0tavihf1af.jpg",
//       "age": 25,
//       "description": "Software Engineer at ABC Corp",
//     },
//     {
//       "id": 2,
//       "user_id": 1,
//       "full_name": "beingbaduga",
//       "profile_photo_url":
//           "https://res.cloudinary.com/dordpmvpm/image/upload/v1725375417/fdwkcqlvzappfpi9dnjt.jpg",
//       "age": 27,
//       "description": "Loves travelling and photography",
//     },
//     // ... more if needed
//   ];

//   String _searchQuery = '';
//   int _currentIndex = 0;

//   List<Map<String, dynamic>> get _filteredMembers {
//     if (_searchQuery.isEmpty) {
//       return _members;
//     }
//     return _members.where((member) {
//       // Filter by full_name (or any other property)
//       final name = member['full_name']?.toLowerCase() ?? '';
//       return name.contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   final List<String> _titles = [
//     'Find Your Partner',
//     'Profile',
//     'Notifications',
//     'Payment',
//   ];

//   final List<Widget> _pages = [];

//   get packageId => null;

//   @override
//   void initState() {
//     super.initState();
//     // Pages for each BottomNavigationBar item
//     _pages.add(HomePage(members: _filteredMembers));
//     _pages.add(EditProfilePage());
//     _pages.add(NotificationPage());
//     _pages.add(MatriUpload(
//       user: widget.user,
//       packageId: packageId,
//     ));
//   }

//   void onTabTapped(int index) {
//     setState(() => _currentIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: theme.appBarTheme.backgroundColor,
//         elevation: 4,
//         title: Text(
//           _titles[_currentIndex], // Dynamic title
//           style: theme.appBarTheme.titleTextStyle,
//         ),
//         centerTitle: true,
//         iconTheme: theme.appBarTheme.iconTheme,
//       ),
//       body: _pages[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: onTabTapped,
//         items: const [
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

// // ----------------------------- HOME PAGE --------------------------------
// class HomePage extends StatelessWidget {
//   final List<Map<String, dynamic>> members;

//   HomePage({required this.members});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           // Search bar
//           Container(
//             decoration: BoxDecoration(
//               color: theme.hintColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(30.0),
//             ),
//             padding:
//                 const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search profiles...',
//                       hintStyle: GoogleFonts.montserrat(
//                         color: theme.hintColor,
//                         fontSize: 16,
//                       ),
//                       border: InputBorder.none,
//                     ),
//                     style: GoogleFonts.montserrat(
//                       color: theme.textTheme.bodyMedium?.color,
//                       fontSize: 16,
//                     ),
//                     onChanged: (value) {
//                       // If you want to implement search logic, do it here
//                     },
//                   ),
//                 ),
//                 Icon(Icons.search, color: theme.hintColor),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20.0),
//           // Profile list
//           Expanded(
//             child: ListView.builder(
//               itemCount: members.length,
//               itemBuilder: (context, index) {
//                 final member = members[index];
//                 return InkWell(
//                   onTap: () {
//                     // Go to details page
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MemberDetails(member: member),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     margin: const EdgeInsets.symmetric(vertical: 10.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15.0),
//                     ),
//                     elevation: 3,
//                     color: theme.primaryColor.withOpacity(0.9),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Profile image
//                           CircleAvatar(
//                             radius: 50,
//                             backgroundImage: NetworkImage(
//                               member['profile_photo_url'] ?? '',
//                             ),
//                             backgroundColor: Colors.transparent,
//                           ),
//                           SizedBox(width: 16.0),
//                           // Info
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Full name
//                                 Text(
//                                   member['full_name'] ?? 'Unknown Name',
//                                   style: GoogleFonts.montserrat(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 20,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8.0),
//                                 // Age
//                                 Text(
//                                   'Age: ${member['age']?.toString() ?? 'N/A'}',
//                                   style: GoogleFonts.montserrat(
//                                     fontSize: 16,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8.0),
//                                 // Description
//                                 Text(
//                                   member['description'] ?? '',
//                                   style: GoogleFonts.montserrat(
//                                     fontSize: 14,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Icon(Icons.arrow_forward_ios, color: Colors.white),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
