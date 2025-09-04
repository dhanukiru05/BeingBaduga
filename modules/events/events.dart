import 'dart:convert';
import 'package:beingbaduga/modules/events/eventdetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool isGridView = true;
  List<Map<String, String>> events = [];
  List<Map<String, String>> filteredEvents = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController =
      TextEditingController(); // Corrected this line

  @override
  void initState() {
    super.initState();
    fetchEvents();
    searchController.addListener(() {
      _filterEvents();
      setState(() {}); // Update the UI when text changes
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://beingbaduga.com/being_baduga/event.php'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> eventsData = responseData['data'];
          setState(() {
            events = eventsData
                .map((item) {
                  return {
                    'name': item['title'] as String? ?? '',
                    'date': item['event_date'] as String? ?? '',
                    'image': item['imageUrl'] as String? ?? '',
                    'description': item['description'] as String? ?? '',
                  };
                })
                .toList()
                .cast<Map<String, String>>();
            filteredEvents =
                events; // Initialize filteredEvents with all events
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage =
                responseData['message'] as String? ?? 'Unknown error';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load events';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _filterEvents() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredEvents = events.where((event) {
        final name = event['name']!.toLowerCase();
        final date = event['date']!.toLowerCase();
        return name.contains(query) || date.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _filterEvents();
                          FocusScope.of(context)
                              .unfocus(); // Dismiss the keyboard
                          setState(
                              () {}); // Update the UI to remove the suffix icon
                        },
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
        actions: [
          IconButton(
            icon: Icon(
              isGridView ? Icons.list : Icons.grid_view,
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : isGridView
                  ? buildGridView()
                  : buildListView(),
    );
  }

  Widget buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showEventDetails(context, filteredEvents[index]);
          },
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.0),
                    ),
                    child: Image.network(
                      filteredEvents[index]['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Icon(Icons.broken_image));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filteredEvents[index]['name']!,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        filteredEvents[index]['date']!,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        filteredEvents[index]['description']!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showEventDetails(context, filteredEvents[index]);
          },
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(12.0),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(filteredEvents[index]['image']!),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {
                        // Handle image loading error
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filteredEvents[index]['name']!,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          filteredEvents[index]['date']!,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          filteredEvents[index]['description']!,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEventDetails(BuildContext context, Map<String, String> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
    );
  }
}
