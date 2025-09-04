import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../../utils/CPSessionManager.dart';
import '../../utils/PreferenceUtils.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Variables to hold the visibility state of Instagram username
  String instagramUsername = '@Being_baduga';

  // Method to handle URL launching
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Method to handle form submission
  Future<void> _submitForm(
      BuildContext context, String name, String email, String message) async {
    final String apiUrl = 'https://beingbaduga.com/being_baduga/sendemail.php';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'name': name,
          'email': email,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          _showDialog(context, 'Success', 'Message sent successfully!');
        } else {
          _showDialog(context, 'Error', responseData['message']);
        }
      } else {
        _showDialog(
            context, 'Error', 'Failed to send message. Please try again.');
      }
    } catch (e) {
      _showDialog(
          context, 'Error', 'An error occurred. Please try again later.');
    }
  }

  // Helper method to show dialog
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
        actions: [
          IconButton(onPressed: (){
            PreferenceUtils.setInt(CPSessionManager.USER_ID, 0);
            PreferenceUtils.setBool(CPSessionManager.IS_LOGIN, false);
            Navigator.pushReplacementNamed(context, '/login'); // Navigate to Login Page

          }, icon: Icon(Icons.logout))
        ],
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipOval(
                  child: Image.network(
                    'https://res.cloudinary.com/dordpmvpm/image/upload/v1724081028/vkpqmfbcwgxhlyogiglc.jpg',
                    height: 170,
                    width: 170,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20.0), // Space between logo and content
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.locationArrow,
                      color:
                          Theme.of(context).primaryColor), // Theme icon color
                  title: Text('Address',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium), // Theme text color
                  subtitle: Text(
                    'OOTY, Tamil Nadu',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    _launchURL(
                        'https://maps.app.goo.gl/cm7SnzRjgfLnHq928'); // Updated URL
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.instagram,
                      color:
                          Theme.of(context).primaryColor), // Theme icon color
                  title: Text('Instagram',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium), // Theme text color
                  subtitle: Text(
                    instagramUsername, // Display Instagram username
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    setState(() {
                      instagramUsername =
                          ''; // Clear Instagram username when Instagram is pressed
                    });
                    _launchURL('https://www.instagram.com/being_baduga/');
                  },
                ),
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft, // Align left
                child: Text(
                  'Get in Touch',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor, // Primary color
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: messageController,
                          decoration: InputDecoration(
                            labelText: 'Message',
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a message';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _submitForm(
                                context,
                                nameController.text,
                                emailController.text,
                                messageController.text,
                              );
                            }
                          },
                          icon: Icon(Icons.send, color: Colors.white),
                          label: Text(
                            'Submit',
                            style: TextStyle(
                                color: Colors.white), // Button text color
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryColor, // Primary color
                            padding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 50.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
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
