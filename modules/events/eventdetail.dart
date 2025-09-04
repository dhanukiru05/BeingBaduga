import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, String> event;

  EventDetailsPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['name'] ?? 'Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(event['image']!),
            SizedBox(height: 16.0),
            Text(
              event['name']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              event['date']!,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16.0),
            Text(
              event['description']!,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
