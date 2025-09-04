// member_details.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemberDetails extends StatelessWidget {
  final Map<String, dynamic> member;
  final Map<String, dynamic> currentUser;

  const MemberDetails({
    Key? key,
    required this.member,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          member['full_name'] ?? 'Member Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptions(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileImage(context),
            _buildProfileHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Personal Information'),
                  _buildDetailsList(context),
                  SizedBox(height: 20),
                  _buildSectionTitle('Education & Career'),
                  _buildEducationCareerSection(context),
                  SizedBox(height: 20),
                  _buildSectionTitle('Expectations'),
                  _buildExpectations(context),
                  SizedBox(height: 20),
                  _buildDocumentUploadSection(context),
                  SizedBox(height: 20),
                  _buildExpressInterestButton(context),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showZoomableImage(context, member['profile_photo_url']);
      },
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              member['profile_photo_url'] ??
                  'https://via.placeholder.com/600x250',
            ),
            fit: BoxFit.cover, // Cover the container
          ),
        ),
      ),
    );
  }

  void _showZoomableImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(
            member['full_name'] ?? 'Unknown Name',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          // If you also want to show 'age' here, you can do so:
          // Text('Age: ${member['age']?.toString() ?? 'N/A'}',
          //    style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700])),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDetailsList(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // NOTE: Removed DOB references. We'll show 'age' instead:
    String ageStr = member['age'] != null ? member['age'].toString() : 'N/A';
    String gender = member['gender'] ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailCard(
          FontAwesomeIcons.user,
          'Full Name',
          member['full_name'],
          theme,
        ),
        // AGE
        _buildDetailCard(
          FontAwesomeIcons.calendarAlt, // or any icon you'd like
          'Age',
          ageStr, // display the age field
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.venusMars,
          'Gender',
          gender,
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.feather,
          "Father's Name",
          member['father_name'],
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.otter,
          "Mother's Name",
          member['mother_name'],
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.tree,
          'Hatty Name',
          member['hatty_name'],
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.mapMarkerAlt,
          'Seemai',
          member['seemai'],
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.smoking,
          'Smoking/Drinking',
          member['smoke_drink'],
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.heartBroken,
          'Divorce',
          member['divorce'] ?? 'No',
          theme,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEducationCareerSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        _buildDetailCard(
          FontAwesomeIcons.graduationCap,
          'Degree',
          member['degree'],
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.book,
          'Stream/Branch',
          member['stream'],
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.building,
          'Working At',
          member['working_at'],
          theme,
        ),
        _buildDetailCard(
          FontAwesomeIcons.dollarSign,
          'Salary (Annually)',
          member['salary']?.toString(),
          theme,
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String label,
    String? value,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      shadowColor: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            FaIcon(icon, color: theme.primaryColor, size: 20),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpectations(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      shadowColor: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.star_border, color: theme.primaryColor, size: 20),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expectations',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    member['expectations'] ?? 'No expectations mentioned.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    String voterIdUrl = member['aadhaar_pan_dl'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      shadowColor: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: theme.primaryColor, size: 20),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Voter ID (JPEG)',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.visibility, color: theme.primaryColor),
              ],
            ),
            SizedBox(height: 10),
            voterIdUrl.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _showZoomableImage(context, voterIdUrl);
                    },
                    child: Image.network(
                      voterIdUrl,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, url, error) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                  )
                : Text(
                    'No Voter ID uploaded.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpressInterestButton(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: () {
        _expressInterest(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      icon: Icon(Icons.favorite, color: Colors.white, size: 24),
      label: Text(
        'Express Interest',
        style: GoogleFonts.poppins(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _expressInterest(BuildContext context) {
    String recipientEmail = member['email']?.toString() ?? '';
    int recipientId = member['id'];
    int senderId = currentUser['id'];

    if (recipientEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member has no email address.')),
      );
      return;
    }

    final _formKey = GlobalKey<FormState>();
    String userName = '';
    String userEmail = '';
    String userPhone = '';
    String userMessage = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Express Interest', style: GoogleFonts.poppins()),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please provide your details',
                      style: GoogleFonts.poppins()),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter your name'
                        : null,
                    onChanged: (value) => userName = value.trim(),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Your Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter your phone number'
                        : null,
                    onChanged: (value) => userPhone = value.trim(),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Your Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter your email'
                        : null,
                    onChanged: (value) => userEmail = value.trim(),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter a message'
                        : null,
                    onChanged: (value) => userMessage = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Map<String, dynamic> dataForDB = {
                    'sender_id': senderId,
                    'recipient_id': recipientId,
                    'sender_name': userName,
                    'sender_email': userEmail,
                    'sender_phone': userPhone,
                    'message': userMessage,
                  };

                  Map<String, dynamic> dataForEmail = {
                    'recipient_email': recipientEmail,
                    'sender_name': userName,
                    'sender_email': userEmail,
                    'sender_phone': userPhone,
                    'message': userMessage,
                  };

                  try {
                    // 1) Post to express_interest.php
                    final responseDB = await http.post(
                      Uri.parse(
                          'https://beingbaduga.com/being_baduga/express_interest.php'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(dataForDB),
                    );

                    final responseDBData = json.decode(responseDB.body);

                    if (responseDB.statusCode == 200 &&
                        responseDBData['status'] == 'success') {
                      // 2) Send an email via send_interest.php
                      final responseEmail = await http.post(
                        Uri.parse(
                            'https://beingbaduga.com/being_baduga/send_interest.php'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode(dataForEmail),
                      );

                      final responseEmailData = json.decode(responseEmail.body);

                      if (responseEmail.statusCode == 200 &&
                          (responseEmailData['success'] == true ||
                              responseEmailData['status'] == 'success')) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Your interest has been expressed and email sent.'),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            responseEmailData['error'] ??
                                'Interest saved, but failed to send email.',
                          ),
                        ));
                      }

                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          responseDBData['message'] ??
                              'Failed to save your interest. Please try again later.',
                        ),
                      ));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'An error occurred. Please check your connection and try again.',
                      ),
                    ));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.share, color: Colors.blue),
                title: Text('Share Profile', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement share functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text('Block Member', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement block functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.redAccent),
                title: Text('Delete Profile', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement delete functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
