// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:google_fonts/google_fonts.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'dart:convert';

// class MemberDetails extends StatelessWidget {
//   final Map<String, dynamic> member;

//   MemberDetails({required this.member});

//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: theme.primaryColor,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           member['name'] ?? 'Member Details',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: theme.primaryColor,
//         onPressed: () {
//           // Add edit action here
//         },
//         child: Icon(Icons.edit, color: Colors.white),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               theme.primaryColor.withOpacity(0.1),
//               theme.scaffoldBackgroundColor
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildProfileHeader(context),
//                 SizedBox(height: 20),
//                 _buildDetailsList(context),
//                 SizedBox(height: 30),
//                 _buildDocumentUploadSection(),
//                 SizedBox(height: 20),
//                 _buildContactButton(context),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileHeader(BuildContext context) {
//     return Center(
//       child: Column(
//         children: [
//           Stack(
//             alignment: Alignment.bottomRight,
//             children: [
//               CircleAvatar(
//                 radius: 70,
//                 backgroundImage: NetworkImage(
//                   member['photo'] ?? 'https://via.placeholder.com/150',
//                 ),
//                 backgroundColor: Colors.transparent,
//               ),
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 child: Icon(
//                   Icons.camera_alt,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 15),
//           Text(
//             member['name'] ?? 'Unknown Name',
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.bold,
//               fontSize: 26,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 5),
//           // If you also have "age" in your data:
//           Text(
//             '${member['age'] ?? 'N/A'} years old',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailsList(BuildContext context) {
//     final ThemeData theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDetailCard(
//           FontAwesomeIcons.user,
//           'Full Name',
//           member['name'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.male,
//           "Father's Name",
//           member['fatherName'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.female,
//           "Mother's Name",
//           member['motherName'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.venusMars,
//           'Gender',
//           member['gender'],
//           theme,
//         ),

//         // ADD A CARD FOR DOB (Date of Birth):
//         _buildDetailCard(
//           FontAwesomeIcons.calendar,
//           'Date of Birth',
//           member['dob'], // <-- make sure 'dob' is in your member data
//           theme,
//         ),

//         _buildDetailCard(
//           FontAwesomeIcons.tree,
//           'Hatty Name',
//           member['hattyName'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.mapMarkerAlt,
//           'Seemai',
//           member['seemai'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.briefcase,
//           'Occupation',
//           member['occupation'],
//           theme,
//         ),
//         SizedBox(height: 10),
//         _buildCustomDivider(),
//         _buildExpansionTile('Family Status / Wealth', member['familyStatus']),
//         _buildCustomDivider(),
//         _buildDetailCard(
//           FontAwesomeIcons.moneyBill,
//           'Salary (Annually)',
//           member['salary'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.rulerVertical,
//           'Height (in cm)',
//           member['height'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.smoking,
//           'Smoking/Drinking',
//           member['smokingDrinking'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.heartBroken,
//           'Divorce',
//           member['divorce'] ?? 'No',
//           theme,
//         ),
//         SizedBox(height: 20),
//         _buildCustomDivider(),
//         _buildDetailCard(
//           FontAwesomeIcons.graduationCap,
//           'Degree',
//           member['degree'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.book,
//           'Stream/Branch',
//           member['stream'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.building,
//           'Working At (Company)',
//           member['company'],
//           theme,
//         ),
//         _buildDetailCard(
//           FontAwesomeIcons.seedling,
//           'Agriculture or Business',
//           member['agricultureOrBusiness'],
//           theme,
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailCard(
//     IconData icon,
//     String label,
//     String? value,
//     ThemeData theme,
//   ) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       elevation: 3,
//       shadowColor: Colors.grey[200],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             FaIcon(icon, color: theme.primaryColor, size: 24),
//             SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     value ?? 'N/A',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExpansionTile(String title, String? description) {
//     return ExpansionTile(
//       title: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontWeight: FontWeight.bold,
//           fontSize: 16,
//           color: Colors.black87,
//         ),
//       ),
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Text(
//             description ?? 'N/A',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[700],
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildCustomDivider() {
//     return Divider(
//       thickness: 1.5,
//       color: Colors.grey[300],
//       indent: 15,
//       endIndent: 15,
//     );
//   }

//   Widget _buildDocumentUploadSection() {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(Icons.file_present, color: Colors.green, size: 28),
//             SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 'Aadhaar / PAN / Driving License (JPEG)',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContactButton(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: () {
//         _sendSMS();
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.redAccent, // Button color
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         padding: EdgeInsets.symmetric(vertical: 12),
//       ),
//       icon: Icon(Icons.message, size: 20, color: Colors.white),
//       label: Text(
//         'Contact Now',
//         style: GoogleFonts.poppins(
//           fontSize: 18,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   void _sendSMS() async {
//     String message = 'Hi, I would like to get in touch with you.';
//     String numbers = '7200053453';

//     var url = Uri.parse('https://beingbaduga.com/being_baduga/sendSMS.php');

//     var response = await http.post(url, body: {
//       'message': message,
//       'numbers': numbers,
//     });

//     if (response.statusCode == 200) {
//       var jsonResponse = json.decode(response.body);
//       print('Response from API: $jsonResponse');
//     } else {
//       print('Failed to send SMS. Status code: ${response.statusCode}');
//     }
//   }
// }
