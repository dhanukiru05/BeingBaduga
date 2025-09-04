import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  final String moduleName;

  ForgotPasswordPage({required this.moduleName});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isPinSent = false;
  bool _isLoading = false;
  String _statusMessage = '';
  Color _statusColor = Colors.black;

  void _sendPin() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    String email = _emailController.text;

    var url =
        Uri.parse('https://beingbaduga.com/being_baduga/send_pin.php');
    var response = await http.post(url, body: {'email': email});

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _isPinSent = true;
          _statusMessage = 'PIN sent to your email';
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _statusMessage = data['message'];
          _statusColor = Colors.red;
        });
      }
    } else {
      setState(() {
        _statusMessage = 'Failed to send PIN';
        _statusColor = Colors.red;
      });
    }
  }

  void _verifyPinAndResetPassword() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    String email = _emailController.text;
    String pin = _pinController.text;
    String newPassword = _newPasswordController.text;

    var url = Uri.parse(
        'https://beingbaduga.com/being_baduga/verify_pin_and_reset_password.php');
    var response = await http.post(url, body: {
      'email': email,
      'pin': pin,
      'new_password': newPassword,
    });

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _statusMessage = 'Password reset successful! Please login.';
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _statusMessage = data['message'];
          _statusColor = Colors.red;
        });
      }
    } else {
      setState(() {
        _statusMessage = 'Failed to reset password';
        _statusColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        icon: Icons.email,
                        enabled: !_isPinSent,
                      ),
                      SizedBox(height: 20),
                      if (_isPinSent) ...[
                        _buildTextField(
                          controller: _pinController,
                          labelText: 'Enter 6-digit PIN',
                          icon: Icons.lock,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: _newPasswordController,
                          labelText: 'New Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                      ],
                      SizedBox(height: 30),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _isPinSent
                                  ? _verifyPinAndResetPassword
                                  : _sendPin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 48.0,
                                ),
                              ),
                              child: Text(
                                _isPinSent ? 'Reset Password' : 'Send PIN',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).hintColor,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}
