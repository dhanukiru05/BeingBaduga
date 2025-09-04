// business_details.dart
import 'dart:convert'; // Import for JSON decoding
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import FontAwesome

class BusinessDetails extends StatelessWidget {
  final Map<String, dynamic> business;

  BusinessDetails({required this.business});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Debug: Print the business data to verify contents
    print('Business Data: $business');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          business['name'] ?? 'Business Details',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Business Image with Rounded Corners and Shadow
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.network(
                      business['photo'] ??
                          'https://via.placeholder.com/600x400.png?text=No+Image',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[700],
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Business Name and Type
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      business['name'] ?? 'Business Name',
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      business['type'] ?? 'Business Type',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: theme.textTheme.titleMedium?.color
                            ?.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Rating Section (Optional but Recommended)
              _buildRatingSection(business['rating']),
              SizedBox(height: 20),
              // About Us Section
              _buildInfoContainer(
                icon: Icons.info_outline,
                title: 'About Us',
                content: Text(
                  business['description'] ??
                      'No description available for this business.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Services Offered Section
              _buildInfoContainer(
                icon: Icons.build,
                title: 'Services Offered',
                content: _buildBulletList(
                  _parseServices(business),
                ),
              ),
              SizedBox(height: 20),
              // Working Hours Section
              _buildInfoContainer(
                icon: Icons.schedule,
                title: 'Working Hours',
                content: _buildWorkingHours(
                  _parseOperatingHours(business),
                ),
              ),
              SizedBox(height: 20),
              // Contact Information Section
              _buildInfoContainer(
                icon: Icons.contact_mail,
                title: 'Contact Information',
                content: _buildContactInfo(
                  context: context,
                  email: business['email'] ?? 'Not available',
                  phone: business['phone'] ?? 'Not available',
                  address: business['address'] ?? 'Not available',
                ),
              ),
              SizedBox(height: 30),
              // Action Buttons
              _buildActionButtons(context, business['phone']),
              SizedBox(height: 30),
              // Social Media Links Section (Optional)
              _buildSocialMediaLinks(context, business['socialMedia']),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to parse services from the business data
  List<String> _parseServices(Map<String, dynamic> business) {
    if (business['services'] != null) {
      print('Services Data Found: ${business['services']}');
      if (business['services'] is List) {
        return List<String>.from(business['services']);
      } else if (business['services'] is String) {
        // If servicesData is a JSON string, decode it
        try {
          List<dynamic> decoded = json.decode(business['services']);
          return List<String>.from(decoded);
        } catch (e) {
          print('Error decoding services JSON string: $e');
          return [];
        }
      }
    } else if (business['9'] != null) {
      // '9' key contains JSON string of services
      print('Services Data Found under key "9": ${business['9']}');
      try {
        List<dynamic> decoded = json.decode(business['9']);
        return List<String>.from(decoded);
      } catch (e) {
        print('Error decoding services from key "9": $e');
        return [];
      }
    }

    print('No services data available.');
    return [];
  }

  /// Helper method to parse operating hours from the business data
  List<Map<String, dynamic>> _parseOperatingHours(
      Map<String, dynamic> business) {
    if (business['operating_hours'] != null) {
      print('Operating Hours Data Found: ${business['operating_hours']}');
      if (business['operating_hours'] is List) {
        return List<Map<String, dynamic>>.from(business['operating_hours']);
      } else if (business['operating_hours'] is String) {
        // If operatingHoursData is a JSON string, decode it
        try {
          List<dynamic> decoded = json.decode(business['operating_hours']);
          return List<Map<String, dynamic>>.from(decoded);
        } catch (e) {
          print('Error decoding operating_hours JSON string: $e');
          return [];
        }
      }
    } else if (business['operatingHours'] != null) {
      // Some APIs might use camelCase
      print(
          'Operating Hours Data Found under key "operatingHours": ${business['operatingHours']}');
      if (business['operatingHours'] is List) {
        return List<Map<String, dynamic>>.from(business['operatingHours']);
      } else if (business['operatingHours'] is String) {
        try {
          List<dynamic> decoded = json.decode(business['operatingHours']);
          return List<Map<String, dynamic>>.from(decoded);
        } catch (e) {
          print('Error decoding operatingHours from key "operatingHours": $e');
          return [];
        }
      }
    } else if (business['8'] != null) {
      // '8' key contains JSON string of operating_hours
      print('Operating Hours Data Found under key "8": ${business['8']}');
      try {
        List<dynamic> decoded = json.decode(business['8']);
        return List<Map<String, dynamic>>.from(decoded);
      } catch (e) {
        print('Error decoding operatingHours from key "8": $e');
        return [];
      }
    }

    print('No operating hours data available.');
    return [];
  }

  /// Helper method to build information containers with icons
  Widget _buildInfoContainer({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title
            Row(
              children: [
                Icon(icon, color: Colors.pink, size: 28),
                SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Content
            content,
          ],
        ),
      ),
    );
  }

  /// Helper method to build bullet lists
  Widget _buildBulletList(List<String> items) {
    if (items.isEmpty) {
      return Text(
        'No services available.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Helper method to build working hours
  Widget _buildWorkingHours(List<Map<String, dynamic>> hours) {
    if (hours.isEmpty) {
      return Text(
        'No operating hours available.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      );
    }

    return Column(
      children: hours.map((hour) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${hour['day']}: ${hour['hours']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Helper method to build contact information
  Widget _buildContactInfo({
    required BuildContext context,
    required String email,
    required String phone,
    required String address,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email
        GestureDetector(
          onTap: () => _sendEmail(context, email),
          child: Row(
            children: [
              Icon(Icons.email, color: Colors.pink, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        // Phone
        GestureDetector(
          onTap: () => _makePhoneCall(context, phone),
          child: Row(
            children: [
              Icon(Icons.phone, color: Colors.pink, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  phone,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        // Address
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.pink, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                address,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper method to build action buttons
  Widget _buildActionButtons(BuildContext context, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Call Now Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall(context, phoneNumber),
              icon: Icon(Icons.call, color: Colors.white),
              label: Text(
                'Call Now',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
              ),
            ),
          ),
          SizedBox(width: 16),
          // WhatsApp Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openWhatsApp(context, phoneNumber),
              icon: Icon(Icons.message, color: Colors.white),
              label: Text(
                'WhatsApp',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Optional: Helper method to build a Rating section
  Widget _buildRatingSection(dynamic rating) {
    if (rating == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Text(
              rating.toString(),
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Text(
              'Based on reviews',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Optional: Helper method to build social media links
  Widget _buildSocialMediaLinks(BuildContext context, dynamic socialMedia) {
    if (socialMedia == null || socialMedia.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title
            Row(
              children: [
                Icon(Icons.share, color: Colors.pink, size: 28),
                SizedBox(width: 12),
                Text(
                  'Follow Us',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Social Media Icons
            Row(
              children: [
                if (socialMedia['facebook'] != null)
                  _socialMediaIcon(context, FontAwesomeIcons.facebookF,
                      socialMedia['facebook']),
                if (socialMedia['twitter'] != null)
                  _socialMediaIcon(context, FontAwesomeIcons.twitter,
                      socialMedia['twitter']),
                if (socialMedia['instagram'] != null)
                  _socialMediaIcon(context, FontAwesomeIcons.instagram,
                      socialMedia['instagram']),
                if (socialMedia['linkedin'] != null)
                  _socialMediaIcon(context, FontAwesomeIcons.linkedinIn,
                      socialMedia['linkedin']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to create social media icon buttons using FontAwesome
  Widget _socialMediaIcon(BuildContext context, IconData icon, String url) {
    return IconButton(
      icon: FaIcon(icon, color: Colors.blueAccent, size: 30),
      onPressed: () => _launchURL(context, url),
    );
  }

  /// Function to launch URLs (for social media)
  void _launchURL(BuildContext context, String url) async {
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  /// Function to make phone call
  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    if (phoneNumber == 'Not available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number is not available')),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Show a Snackbar instead of throwing an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not initiate phone call')),
      );
    }
  }

  /// Function to open WhatsApp
  void _openWhatsApp(BuildContext context, String phoneNumber) async {
    if (phoneNumber == 'Not available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number is not available')),
      );
      return;
    }

    // Remove any non-digit characters from phone number
    String sanitizedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: sanitizedNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      // Show a Snackbar instead of throwing an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  /// Function to send email
  void _sendEmail(BuildContext context, String email) async {
    if (email == 'Not available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email is not available')),
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Inquiry about your services',
      }),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send email')),
      );
    }
  }

  /// Function to encode query parameters for email
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
