// lib/expired_page.dart

import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/homepage.dart';
import 'package:beingbaduga/modules/cart/cart.dart';
import 'package:flutter/material.dart';

class ExpiredPage extends StatelessWidget {
  final String featureName;
  final User user; // Receive the User object

  const ExpiredPage({
    Key? key,
    required this.featureName,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$featureName Access Expired'),
        centerTitle: true,
        // The AppBar uses the theme's AppBarTheme by default
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enhanced Icon with Animation
              AnimatedScale(
                scale: 1.1,
                duration: Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(30),
                  child: Icon(
                    Icons.lock_outline,
                    color: theme.primaryColor,
                    size: 60,
                    semanticLabel: 'Access Expired Icon',
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Title Text
              Text(
                'Access Expired',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // Informative Message
              Text(
                'Your access to "$featureName" has expired. Please renew your subscription to continue enjoying this feature.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40),
              // Renew Subscription Button with Gradient
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the Cart Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(
                          user: user,
                        ), // Pass necessary parameters if any
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5, // Makes the button transparent
                    shadowColor:
                        Colors.transparent, // Removes the default shadow
                  ).copyWith(
                    // Use Ink to apply gradient
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => Colors.transparent,
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.hintColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(minHeight: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, size: 20, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Renew Subscription',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Go Back Home Button with Enhanced Outlined Style
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate back to the Home Page
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(user: user),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 20, color: theme.primaryColor),
                      SizedBox(width: 10),
                      Text(
                        'Go to Home',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Additional Support Section (Optional)
              TextButton(
                onPressed: () {
                  // Navigate to Support or Contact Page
                  // Navigator.push(...);
                },
                child: Text(
                  'Need Help?',
                  style: TextStyle(
                    color: theme.primaryColor,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
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
