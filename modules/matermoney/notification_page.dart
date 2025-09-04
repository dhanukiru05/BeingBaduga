import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'name': 'John Doe',
      'phone': '+1234567890',
      'age': '30',
      'description': 'John has sent you a message.',
      'photoUrl': 'https://via.placeholder.com/150' // Placeholder photo
    },
    {
      'name': 'Jane Smith',
      'phone': '+0987654321',
      'age': '28',
      'description': 'Jane has shared a document with you.',
      'photoUrl': 'https://via.placeholder.com/150'
    },
  ];

  // Function to make a phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  // Function to show notification details in a popup
  void _showNotificationDetails(
      BuildContext context, Map<String, String> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          contentPadding: EdgeInsets.all(16), // Add padding for better layout
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display name
              Text(
                notification['name'] ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 10),

              // Display phone number
              Row(
                children: [
                  Icon(Icons.phone, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    notification['phone'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Display age
              Row(
                children: [
                  Icon(Icons.cake, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Age: ${notification['age'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Display description
              Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 8),
              Text(
                notification['description'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 30),

              // Call button at the bottom
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(Icons.phone, color: Colors.white),
                  label: Text(
                    'Call Now',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: () => _makePhoneCall(notification['phone']!),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(notification['photoUrl']!),
                radius: 30,
              ),
              title: Text(
                notification['name']!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                notification['description']!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () => _showNotificationDetails(context, notification),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Theme.of(context).hintColor),
            ),
          );
        },
      ),
    );
  }
}
