import 'dart:convert';

import 'package:flutter/material.dart';

import '../../User_Model.dart';
import '../../razorPay_payment_page.dart';
import '../../utils/CPSessionManager.dart';
import '../../utils/PreferenceUtils.dart';

class PaymentPage extends StatelessWidget {
  final String currentPackage = "View Only"; // Current package
  final String newPackage = "Post"; // Upgrade package

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.2),
              theme.scaffoldBackgroundColor
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image and Current Package Section
            _buildHeader(context),
            SizedBox(height: 30),
            _buildCurrentPackageCard(context),
            SizedBox(height: 30),
            // Upgrade Package Section
            _buildUpgradePackageCard(context),
            Spacer(),
            // Upgrade Button at the bottom
            _buildUpgradeButton(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build header with profile picture and welcome message
  Widget _buildHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
                'https://res.cloudinary.com/dordpmvpm/image/upload/v1725135496/z9nzcj2ijq6gira5ceuw.jpg'),
          ),
          SizedBox(height: 15),
          Text(
            'Welcome to the Payment Page',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build current package card
  Widget _buildCurrentPackageCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Package',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.visibility,
                size: 40,
                color: Colors.blueAccent,
              ),
              title: Text(
                currentPackage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                'You currently have access to view profiles.',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build upgrade package card
  Widget _buildUpgradePackageCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upgrade to Post Package',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.upgrade,
                size: 40,
                color: Colors.green,
              ),
              title: Text(
                newPackage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                'Get full access to post and interact with profiles.',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build upgrade button
  Widget _buildUpgradeButton(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ElevatedButton(
      onPressed: () {
        // Handle upgrade action
        /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upgrade to Post Package')),
        );*/
        /* var jsonEncode = PreferenceUtils.getString(CPSessionManager.USER);
        var user =
        User.fromJson(jsonDecode(jsonEncode));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RazorPayPaymentPage(name:user.name ,phoneNumber:user.phone ,email:user.email ,amount:"1.00" ,packageName:user ,categoryName: ,),
          ),
        );*/
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor, // Upgrade button color
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Upgrade Now',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
