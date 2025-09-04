import 'dart:convert';

import 'package:beingbaduga/login.dart';
import 'package:beingbaduga/utils/CPSessionManager.dart';
import 'package:beingbaduga/utils/PreferenceUtils.dart';
import 'package:flutter/material.dart';

import 'User_Model.dart';
import 'homepage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);

    // Navigate to Homepage after 5 seconds
    Future.delayed(Duration(seconds: 3), () {
      _navigateToHomepage();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBE1744), // Set the background color
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Container(
            width: 200, // Adjust the size as needed
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2), // Black border
            ),
            child: ClipOval(
              child: Image.network(
                'https://res.cloudinary.com/dordpmvpm/image/upload/v1724081028/vkpqmfbcwgxhlyogiglc.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHomepage() {
    bool isLogin = PreferenceUtils.getBool(CPSessionManager.IS_LOGIN);

    if (isLogin) {
      var jsonEncode = PreferenceUtils.getString(CPSessionManager.USER);
      var user = User.fromJson(jsonDecode(jsonEncode));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home(user: user)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginPage(), // Replace with your Homepage widget
        ),
      );
    }
  }
}
