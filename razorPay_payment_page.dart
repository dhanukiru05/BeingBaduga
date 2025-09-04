import 'package:flutter/material.dart';
import 'RazorPage.dart'; // Ensure this import points to the correct file

class RazorPayPaymentPage extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String email;
  final String amount;
  final String packageName;
  final String categoryName;

  RazorPayPaymentPage({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.amount,
    required this.packageName,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty or null categoryName
    final displayCategoryName = categoryName.isNotEmpty ? categoryName : "Unknown Category";

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display payment details inside a card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with an icon
                    Row(
                      children: [
                        Icon(Icons.person, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Name:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Phone Number with an icon
                    Row(
                      children: [
                        Icon(Icons.phone, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Phone Number:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                      child: Text(
                        phoneNumber,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Email with an icon
                    Row(
                      children: [
                        Icon(Icons.email, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Email:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                      child: Text(
                        email,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Category Name with an icon
                    Row(
                      children: [
                        Icon(Icons.category, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Category:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                      child: Text(
                        displayCategoryName,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Package Name with an icon
                    Row(
                      children: [
                        Icon(Icons.card_giftcard, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Package:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                      child: Text(
                        packageName,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Amount with an icon
                    Row(
                      children: [
                        Icon(Icons.money, color: Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Total Amount:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                      child: Text(
                        '₹$amount',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            // Proceed to Payment button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RazorPage(
                      amount: amount,
                      packageName: packageName,
                      categoryName: displayCategoryName, userId: '', categoryId: '', packageId: '', duration: '',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 48.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Proceed to Payment',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
