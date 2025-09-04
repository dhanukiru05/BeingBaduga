// lib/not_available_page.dart

import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/homepage.dart';
import 'package:beingbaduga/modules/about/contact.dart';
import 'package:beingbaduga/modules/cart/cart.dart';
import 'package:flutter/material.dart';

class NotAvailablePage extends StatelessWidget {
  final String featureName;
  final User user; // Receive the User object

  const NotAvailablePage({
    Key? key,
    required this.featureName,
    required this.user,
  }) : super(key: key);

  get currencyFormat => null;

  get totalAmount => null;

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$featureName Registration'),
        centerTitle: true,
        // The AppBar uses the theme's AppBarTheme by default
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Relevant Icon with Animation
              AnimatedScale(
                scale: 1.1,
                duration: Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.hintColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(30),
                  child: Icon(
                    Icons.how_to_reg, // Icon representing registration
                    color: theme.hintColor,
                    size: 60,
                    semanticLabel: '$featureName Registration Icon',
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Title Text
              Text(
                'Register for $featureName',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // Informative Message
              Text(
                'You have not registered for "$featureName".\n\nPlease register to access and enjoy all the features this service offers.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(
                          user: user,
                        ),
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
                          Icon(Icons.person_add, size: 20, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Register Now',
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
                child: OutlinedButton.icon(
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
                  icon: Icon(Icons.home, size: 20, color: theme.primaryColor),
                  label: Text(
                    'Go to Home',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Additional Support Section (Optional)
              TextButton(
                onPressed: () {
                  // Navigate to Support or Contact Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactPage(),
                    ),
                  );
                },
                child: Text(
                  'Need More Help?',
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
