import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'User_Model.dart'; // Import your user model

// NotificationPage
class NotificationPagee extends StatefulWidget {
  final User user; // Pass the logged-in User

  NotificationPagee({required this.user});

  @override
  _NotificationPageeState createState() => _NotificationPageeState();
}

class _NotificationPageeState extends State<NotificationPagee> {
  late Future<List<Map<String, dynamic>>> futureNotifications;

  @override
  void initState() {
    super.initState();
    futureNotifications = fetchNotifications(
        widget.user.id); // Fetch notifications based on logged-in user
  }

  // Fetch notifications from API based on user ID
  Future<List<Map<String, dynamic>>> fetchNotifications(int userId) async {
    final response = await http.get(Uri.parse(
        'https://beingbaduga.com/being_baduga/fetch_notifications.php?user_id=$userId')); // Update with your actual API endpoint
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return List<Map<String, dynamic>>.from(jsonResponse['data']);
      } else {
        throw Exception('Failed to load notifications');
      }
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Refresh the notifications list
  Future<void> _refreshNotifications() async {
    setState(() {
      futureNotifications = fetchNotifications(widget.user.id);
    });
    await futureNotifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Color(0xFFBE1744), // Theme color
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _refreshNotifications();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureNotifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE1744)),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 16),
                ),
              );
            } else if (snapshot.hasData) {
              final notifications = snapshot.data!;
              return notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No new notifications',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            child: ListTile(
                              leading: notification['image_url'] != null &&
                                      notification['image_url'].isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        notification['image_url'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.redAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.notifications_active,
                                        color: Color(0xFFBE1744),
                                      ),
                                    ),
                              title: Text(
                                notification['title'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFFBE1744),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 6),
                                  Text(
                                    notification['message'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${notification['sent_at'] ?? ''}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationDetailsPage(
                                      title: notification['title'] ?? '',
                                      message: notification['message'] ?? '',
                                      date: notification['sent_at']
                                              ?.split(' ')[0] ??
                                          '',
                                      time: notification['sent_at']
                                              ?.split(' ')[1] ??
                                          '',
                                      imageUrl: notification['image_url'] ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
            } else {
              return Center(child: Text('No notifications found'));
            }
          },
        ),
      ),
    );
  }
}

// Notification Details Page
class NotificationDetailsPage extends StatelessWidget {
  final String title;
  final String message;
  final String date;
  final String time;
  final String imageUrl;

  NotificationDetailsPage({
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Details'),
        backgroundColor: Color(0xFFBE1744),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PhotoView(
                        imageProvider: NetworkImage(imageUrl),
                        backgroundDecoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      ),
                    ),
                  )
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            SizedBox(height: 30),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFFBE1744),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey,
                ),
                SizedBox(width: 4),
                Text(
                  '$date at $time',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Divider(height: 30, thickness: 1),
            Text(
              message,
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
