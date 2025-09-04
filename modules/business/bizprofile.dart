import 'dart:convert';
import 'package:beingbaduga/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

class BizProfile extends StatefulWidget {
  final User user; // User object passed from the previous screen

  const BizProfile({super.key, required this.user});

  @override
  _BizProfileState createState() => _BizProfileState();
}

class _BizProfileState extends State<BizProfile> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> businessPackages = [];

  final String apiUrlCategories =
      'https://beingbaduga.com/being_baduga/check_categories.php';

  @override
  void initState() {
    super.initState();
    _fetchBusinessPackages();
  }

  /// Fetches the business package details from the API.
  Future<void> _fetchBusinessPackages() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlCategories),
        body: {
          'action': 'get_categories', // Adjust the action based on your API
          'user_id': widget.user.id.toString(),
        },
      );

      // Debug: Print the raw response
      print('Categories Response status: ${response.statusCode}');
      print('Categories Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Ensure 'services' exists and is a list
        if (data['services'] != null && data['services'] is List<dynamic>) {
          final services = data['services'] as List<dynamic>;

          // Filter services where category_name is 'business' and package_status is 'Available'
          final businesses = services.where((service) {
            final categoryName =
                service['category_name']?.toString().toLowerCase();
            final packageStatus =
                service['package_status']?.toString().toLowerCase();
            return categoryName == 'business' && packageStatus == 'available';
          }).toList();

          if (businesses.isNotEmpty) {
            setState(() {
              businessPackages = businesses
                  .map((business) => business as Map<String, dynamic>)
                  .toList();
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage =
                  'No available Business package found for this user.';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = 'Business services are currently not available.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Network Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception in fetching business packages: $e');
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  /// Calculates the number of days left until the expiry date.
  int _calculateDaysLeft(String expiryDate) {
    try {
      DateTime expiry = DateFormat('yyyy-MM-dd').parse(expiryDate);
      DateTime today = DateTime.now();
      return expiry.difference(today).inDays;
    } catch (e) {
      print('Error parsing date: $e');
      return 0;
    }
  }

  /// Formats date to dd-MM-yyyy.
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      print('Error formatting date: $e');
      return 'N/A';
    }
  }

  /// Displays a SnackBar with the provided message.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildUserDetails() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Details Header
            Row(
              children: [
                Icon(Icons.person, color: Color(0xFFBE1744)),
                SizedBox(width: 10),
                Text(
                  'User Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBE1744),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey),
            SizedBox(height: 10),
            // Name
            Row(
              children: [
                Icon(Icons.account_circle, color: Color(0xFFBE1744)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Name:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.user.name.isNotEmpty ? widget.user.name : 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Phone
            Row(
              children: [
                Icon(Icons.phone, color: Color(0xFFBE1744)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Phone:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.user.phone.isNotEmpty ? widget.user.phone : 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Email
            Row(
              children: [
                Icon(Icons.email, color: Color(0xFFBE1744)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Email:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.user.email.isNotEmpty ? widget.user.email : 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Gender
            Row(
              children: [
                Icon(Icons.wc, color: Color(0xFFBE1744)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gender:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.user.gender.isNotEmpty ? widget.user.gender : 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Age
            Row(
              children: [
                Icon(Icons.cake, color: Color(0xFFBE1744)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Age:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.user.age > 0 ? '${widget.user.age}' : 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Set background color

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // User Details
                        _buildUserDetails(),
                        SizedBox(height: 20),
                        // Package Details List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: businessPackages.length,
                          itemBuilder: (context, index) {
                            final package = businessPackages[index];

                            // Calculate days left once per package
                            final daysLeft = _calculateDaysLeft(
                                package['service_end_date'] ?? '0');

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Package Details Header
                                    Row(
                                      children: [
                                        Icon(Icons.business,
                                            color: Color(0xFFBE1744)),
                                        SizedBox(width: 10),
                                        Text(
                                          'Package Details',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFBE1744),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Divider(color: Colors.grey),
                                    SizedBox(height: 10),
                                    // Package Name
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: Color(0xFFBE1744)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Package Name:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          package['package_name'] ?? 'N/A',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Price
                                    Row(
                                      children: [
                                        Icon(Icons.attach_money,
                                            color: Color(0xFFBE1744)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Price:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₹${package['price'] ?? '0.00'}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Duration
                                    Row(
                                      children: [
                                        Icon(Icons.timer,
                                            color: Color(0xFFBE1744)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Duration:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${package['duration']} days',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Service Start Date
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: Color(0xFFBE1744)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Paid Date:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatDate(
                                              package['service_start_date'] ??
                                                  'N/A'),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Expiry Date
                                    Row(
                                      children: [
                                        Icon(Icons.event_busy,
                                            color: Color(0xFFBE1744)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Expiry Date:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatDate(
                                              package['service_end_date'] ??
                                                  'N/A'),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Days Left
                                    Row(
                                      children: [
                                        Icon(Icons.timelapse,
                                            color: Color(0xFFBE1744)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Days Left:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$daysLeft days',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: daysLeft < 0
                                                ? Colors.red
                                                : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        // Renew Package Button (Visible if any package is expired)
                        if (businessPackages.any((package) =>
                            _calculateDaysLeft(
                                package['service_end_date'] ?? '0') <
                            0))
                          ElevatedButton(
                            onPressed: () {
                              // Implement package renewal functionality
                              _showMessage(
                                  'Renew Package functionality not implemented.');
                            },
                            child: Text(
                              'Renew Package',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFBE1744),
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
