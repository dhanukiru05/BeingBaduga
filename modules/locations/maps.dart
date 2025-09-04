import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<Map<String, dynamic>> mapLocations = [];
  List<Map<String, dynamic>> filteredLocations = [];
  TextEditingController searchController =
      TextEditingController(); // Use TextEditingController

  @override
  void initState() {
    super.initState();
    fetchLocations();
    searchController.addListener(_filterLocations);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchLocations() async {
    try {
      final response = await http.get(
          Uri.parse('https://beingbaduga.com/being_baduga/get_location.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          mapLocations =
              data.map((item) => item as Map<String, dynamic>).toList();
          filteredLocations = mapLocations;
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  void _filterLocations() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredLocations = mapLocations.where((location) {
        final name = (location['name'] ?? '').toLowerCase();
        final timing = (location['timing'] ?? '').toLowerCase();
        return name.contains(query) || timing.contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    searchController.clear();
    _filterLocations();
    FocusScope.of(context).unfocus(); // Dismiss the keyboard
    setState(() {}); // Update the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Locations'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search locations...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: filteredLocations.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                final location = filteredLocations[index];
                return _buildMapTile(context, location);
              },
            ),
    );
  }

  Widget _buildMapTile(BuildContext context, Map<String, dynamic> location) {
    return GestureDetector(
      onTap: () async {
        final url = location['mapUrl'] as String;
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5.0,
        margin: EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            // Location Image
            Container(
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
                image: DecorationImage(
                  image: NetworkImage(location['imageUrl'] as String),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    // Handle image loading error
                  },
                ),
              ),
            ),
            // Name and Timing
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Icon
                  Icon(
                    Icons.location_on,
                    color: Color(0xFFEC407A),
                    size: 24.0,
                  ),
                  SizedBox(width: 8.0), // Space between icon and text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location['name'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEC407A),
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Timing: ${location['timing'] as String}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ),
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
