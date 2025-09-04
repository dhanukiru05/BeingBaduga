import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/homepage.dart';
import 'package:beingbaduga/login.dart';
import 'package:beingbaduga/utils/CPSessionManager.dart';
import 'package:beingbaduga/utils/DeviceHandler.dart';
import 'package:beingbaduga/utils/PreferenceUtils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting

class RegistrationPage extends StatefulWidget {
  late final User user; // Add this line to accept User

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  String _selectedGender = 'Male';
  int? _age;
  bool _isLoading = false; // Track if the registration process is loading

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Register user
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog('Passwords do not match');
        return;
      }

      setState(() {
        _isLoading = true; // Start loading when registration starts
      });

      try {
        final response = await http.post(
          Uri.parse('https://beingbaduga.com/being_baduga/register_user.php'),
          body: {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneNumberController.text.trim(),
            'password': _passwordController.text,
            'dob': _dobController.text, // Save DOB
            'age': _age?.toString() ?? '', // Save Age
            'gender': _selectedGender, // Save Gender
            'fcm_token': PreferenceUtils.getString(
                CPSessionManager.TOKEN_ID), // FCM Token
            'device_type': "Android", // Device Type
            'phone_model': DeviceHandler().modelName, // Phone Model
            // Convert the boolean value to a string ('true' or 'false')
            'notification_enabled': 'true', // or 'false'
          },
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['status'] == 'success') {
            _showSuccessDialog(
                'Registration successful! Please proceed to payment.');
          } else {
            _showErrorDialog(jsonResponse['message'] ?? 'Registration failed.');
          }
        } else {
          _showErrorDialog('Failed to connect to the server');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false; // Stop loading after registration completes
        });
      }
    }
  }

  /// Calculate age based on DOB
  void _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    setState(() {
      _age = age;
    });
  }

  /// Select Date of Birth
  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        _calculateAge(picked);
      });
    }
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

  /// Show Success Dialog
  void _showSuccessDialog(String message) {
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
              _navigateToHome(); // Navigate to main.dart's HomePage
            },
            child: Text('Proceed to login',
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  /// Navigate to Home Page (main.dart)
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Being Baduga'),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading spinner if true
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 10,
                  color: Colors.white, // Ensure the card is white
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: Image.network(
                              'https://res.cloudinary.com/dordpmvpm/image/upload/v1724081028/vkpqmfbcwgxhlyogiglc.jpg',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Register with Being Baduga',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: 'Name',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              // Simple email validation
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Phone Number Field
                          _buildTextField(
                            controller: _phoneNumberController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }
                              // Simple phone number validation
                              if (!RegExp(r'^\+?[0-9]{7,15}$')
                                  .hasMatch(value.trim())) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Password Field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Confirm Password Field
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // DOB and Age Fields
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _dobController,
                                  label: 'Date of Birth',
                                  icon: Icons.calendar_today,
                                  readOnly: true,
                                  onTap: () => _selectDOB(context),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Select your DOB';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Age',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      alignment: Alignment.center,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        _age != null ? '$_age' : 'N/A',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Gender Dropdown
                          _buildDropdownField(
                            label: 'Gender',
                            value: _selectedGender,
                            items: ['Male', 'Female', 'Other']
                                .map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your gender';
                              }
                              return null;
                            },
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue!;
                              });
                            },
                          ),
                          SizedBox(height: 30),
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                              ),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  /// Helper method to build TextFormField widgets
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    void Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).hintColor,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  /// Helper method to build DropdownButtonFormField widgets
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).hintColor,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
