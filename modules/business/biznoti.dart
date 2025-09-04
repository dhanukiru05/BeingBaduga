import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class NotificationItem {
  final String title;
  final String imageUrl;
  final String description;
  final DateTime dateTime;

  NotificationItem({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.dateTime,
  });
}

class BizNotificationPage extends StatelessWidget {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Welcome to Our Service',
      imageUrl:
          'https://via.placeholder.com/150', // Replace with your image URLs
      description:
          'Thank you for joining our platform. We are excited to have you!',
      dateTime: DateTime.now().subtract(Duration(minutes: 15)),
    ),
    NotificationItem(
      title: 'New Feature Released',
      imageUrl: 'https://via.placeholder.com/150',
      description:
          'Check out the new features we have added to enhance your experience.',
      dateTime: DateTime.now().subtract(Duration(hours: 2)),
    ),
    NotificationItem(
      title: 'Maintenance Scheduled',
      imageUrl: 'https://via.placeholder.com/150',
      description:
          'We will be performing scheduled maintenance on our servers.',
      dateTime: DateTime.now().subtract(Duration(days: 1)),
    ),
    // Add more notifications as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  notification.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBE1744)),
              ),
              subtitle: Text(
                notification.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                DateFormat('dd MMM, hh:mm a').format(notification.dateTime),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NotificationDetailPage(notification: notification)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class NotificationDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailPage({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notification.title),
        backgroundColor: Color(0xFFBE1744),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              child: Container(
                height: 250,
                width: double.infinity,
                child: PhotoView(
                  imageProvider: NetworkImage(notification.imageUrl),
                  backgroundDecoration: BoxDecoration(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a')
                        .format(notification.dateTime),
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    notification.description,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
