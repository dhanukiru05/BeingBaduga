// lib/pages/login_page.dart

import 'dart:developer';

import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/forgot_password.dart';
import 'package:beingbaduga/registration_page.dart';
import 'package:beingbaduga/utils/CPSessionManager.dart';
import 'package:beingbaduga/utils/PreferenceUtils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:beingbaduga/homepage.dart'; // Update the path as per your project structure

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for input fields
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _statusMessage = '';
  Color _statusColor = Colors.black;

  bool _isPasswordVisible = false; // For password visibility toggle

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Perform login action
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _statusMessage = ''; // Clear any previous status messages
      });

      String emailOrPhone = _emailOrPhoneController.text.trim();
      String password = _passwordController.text;

      var url =
          Uri.parse('https://beingbaduga.com/being_baduga/login_user.php');

      try {
        var response = await http.post(url, body: {
          'email_or_phone': emailOrPhone,
          'password': password,
          'fcm_token': PreferenceUtils.getString(CPSessionManager.TOKEN_ID),
          // Add other necessary fields if required
        });

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);

          if (data['status'] == 'success') {
            if (data['user'] != null && data['user'] is Map<String, dynamic>) {
              // Extract user data from the response
              User user = User.fromJson(data['user']);

              // Option 1: Show status message and navigate after delay
              setState(() {
                _statusMessage = 'Login successful! Redirecting...';
                _statusColor = Colors.green;
              });

              // Navigate to HomePage with user data after a short delay
              Future.delayed(Duration(seconds: 1), () {
                _navigateToHomePage(user);
              });

              // Option 2: Show success dialog (uncomment if preferred)
              /*
              _showSuccessDialog('Login successful! Redirecting...', user);
              */
            } else {
              // Handle case where 'user' is null or not a map
              setState(() {
                _statusMessage = 'User data is missing in the response.';
                _statusColor = Colors.red;
              });
            }
          } else {
            setState(() {
              _statusMessage = data['message'] ?? 'Login failed.';
              _statusColor = Colors.red;
            });
          }
        } else {
          setState(() {
            _statusMessage = 'Failed to connect to the server';
            _statusColor = Colors.red;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'An error occurred: $e';
          _statusColor = Colors.red;
        });
      }
    }
  }

  /// Navigate to Home Page after successful login
  void _navigateToHomePage(User user) {
    var encodeLoginData = jsonEncode(user);
    final loginResponse = userResponseFromJson(encodeLoginData.toString());
    log("Data Respose : ${jsonEncode(loginResponse)}");
    PreferenceUtils.putString(CPSessionManager.USER, encodeLoginData);
    PreferenceUtils.setInt(CPSessionManager.USER_ID, user.id);
    PreferenceUtils.setBool(CPSessionManager.IS_LOGIN, true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home(user: user)),
    );
  }

  /// Navigate to Registration Page
  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationPage(),
      ),
    );
  }

  /// Navigate to Forgot Password Page
  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(
          moduleName: '',
        ),
      ),
    );
  }

  /// Show Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  /// Show Success Dialog (Optional)
  void _showSuccessDialog(String message, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the success dialog
              _navigateToHomePage(user); // Navigate to HomePage with User
            },
            child: Text('Proceed to Home',
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Login'),
          centerTitle: true, // Center the title for better UI
          backgroundColor:
              Theme.of(context).primaryColor, // Ensure AppBar color
        ),
        body: Center(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Message
              if (_statusMessage.isNotEmpty) ...[
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
              ],
              // Login Card with Logo Inside
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 10,
                color: Colors.white, // Ensure the card is white
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo or Image inside the Card
                      ClipOval(
                        child: Image.network(
                          'https://res.cloudinary.com/dordpmvpm/image/upload/v1724081028/vkpqmfbcwgxhlyogiglc.jpg',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error,
                                size: 50, color: Colors.red);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      // Header Text
                      Text(
                        'Login to your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Form Fields
                      Form(
                        key: _formKey, // Assign the form key
                        child: Column(
                          children: [
                            // Email or Phone Number Field
                            _buildTextField(
                              controller: _emailOrPhoneController,
                              labelText: 'Email or Phone Number',
                              icon: Icons.person,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email or phone number';
                                }
                                // Optional: Add more validation if needed
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            // Password Field with Visibility Toggle
                            _buildTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              icon: Icons.lock,
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).hintColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 30),
                            // Login Button
                            _isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                        horizontal: 48.0,
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                            SizedBox(height: 20),
                            // Forgot Password Link
                            GestureDetector(
                              onTap: _navigateToForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFFEC407A),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // Registration Link
                            GestureDetector(
                              onTap: _navigateToRegistration,
                              child: RichText(
                                text: TextSpan(
                                  text: 'New to ',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Being Baduga',
                                      style: TextStyle(
                                        color: Color(0xFFEC407A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '? Click here to Register',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )));
  }

  // Text field widget with validation and optional suffixIcon
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool readOnly = false,
    void Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).hintColor,
        ),
        suffixIcon: suffixIcon, // Optional suffix icon
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor, // Set to AppBar color
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor, // Set to AppBar color
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor, // Set to AppBar color
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}
