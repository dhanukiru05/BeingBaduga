import 'dart:convert';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/modules/business/biznoti.dart';
import 'package:beingbaduga/modules/business/bizprofile.dart';
import 'package:beingbaduga/modules/business/bizupload.dart';
import 'package:beingbaduga/modules/business/business_details.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BusinessPage extends StatefulWidget {
  final User user;
  final int packageId;

  const BusinessPage({
    Key? key,
    required this.user,
    required this.packageId,
  }) : super(key: key);

  @override
  _BusinessPageState createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  // Current index for Bottom Navigation Bar
  int _currentIndex = 0;

  // Dynamic Business Data
  List<Map<String, dynamic>> _businesses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Search Controller
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBusinesses = [];

  // Track tapped text colors
  Map<int, Color> _tappedTextColors = {};

  // Slider Images from DB
  List<String> _sliderImages = [];
  bool _isSliderLoading = true;
  String? _sliderError;

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
    _fetchSliderImages();
    _searchController.addListener(_filterBusinesses);
  }

  // ------------------ FETCH BUSINESSES ------------------ //
  Future<void> _fetchBusinesses() async {
    final String url = 'https://beingbaduga.com/being_baduga/buis_get.php';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Debugging: Print the API response
        print('Business API Response: $data');

        if (data is Map<String, dynamic>) {
          if (data['status'] == 'success' && data['data'] is List) {
            final List<dynamic> businessesData = data['data'];

            setState(() {
              _businesses = businessesData.map<Map<String, dynamic>>((item) {
                return _parseBusiness(item);
              }).toList();
              _filteredBusinesses = _businesses;
              _isLoading = false;
            });
          } else if (data['status'] == 'success' && data['data'] == null) {
            setState(() {
              _errorMessage = 'No businesses found.';
              _isLoading = false;
            });
          } else if (data['status'] == 'error' && data.containsKey('message')) {
            setState(() {
              _errorMessage = data['message'].toString();
              _isLoading = false;
            });
          } else {
            setState(() {
              _errorMessage = 'Unexpected response structure.';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Unexpected response format.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load businesses. Status Code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // ------------------ PARSE A SINGLE BUSINESS ------------------ //
  Map<String, dynamic> _parseBusiness(dynamic item) {
    if (item is Map<String, dynamic>) {
      return {
        'business_id': item['business_id'] ?? '',
        'name': item['name'] ?? 'No Name',
        'type': item['type'] ?? 'No Type',
        'email': item['email'] ?? 'No Email',
        'phone': item['phone'] ?? 'No Phone',
        'address': item['address'] ?? 'No Address',
        'photo': item['photo'] ?? '',
        'description': item['description'] ?? 'No Description',
        'operatingHours': _parseOperatingHours(item),
        'services': _parseServices(item),
      };
    } else {
      return {
        'business_id': '',
        'name': 'No Name',
        'type': 'No Type',
        'email': 'No Email',
        'phone': 'No Phone',
        'address': 'No Address',
        'photo': '',
        'description': 'No Description',
        'operatingHours': [],
        'services': [],
      };
    }
  }

  // ------------------ PARSE OPERATING HOURS ------------------ //
  List<Map<String, String>> _parseOperatingHours(Map<String, dynamic> item) {
    List<Map<String, String>> operatingHours = [];

    if (item.containsKey('operating_hours')) {
      var hoursData = item['operating_hours'];
      operatingHours = _convertToOperatingHoursList(hoursData);
    } else if (item.containsKey('operatingHours')) {
      var hoursData = item['operatingHours'];
      operatingHours = _convertToOperatingHoursList(hoursData);
    }

    return operatingHours;
  }

  List<Map<String, String>> _convertToOperatingHoursList(dynamic data) {
    List<Map<String, String>> operatingHours = [];

    if (data is List) {
      for (var entry in data) {
        if (entry is Map<String, dynamic>) {
          String day = entry['day']?.toString() ?? 'Unknown Day';
          String hours = entry['hours']?.toString() ?? 'Hours Not Available';
          operatingHours.add({'day': day, 'hours': hours});
        }
      }
    } else if (data is String) {
      try {
        List<dynamic> decoded = json.decode(data);
        for (var entry in decoded) {
          if (entry is Map<String, dynamic>) {
            String day = entry['day']?.toString() ?? 'Unknown Day';
            String hours = entry['hours']?.toString() ?? 'Hours Not Available';
            operatingHours.add({'day': day, 'hours': hours});
          }
        }
      } catch (e) {
        print('Error decoding operating_hours JSON string: $e');
      }
    }

    return operatingHours;
  }

  // ------------------ PARSE SERVICES ------------------ //
  List<String> _parseServices(Map<String, dynamic> item) {
    List<String> services = [];
    if (item.containsKey('services')) {
      var servicesData = item['services'];
      services = _convertToServicesList(servicesData);
    }
    return services;
  }

  List<String> _convertToServicesList(dynamic data) {
    List<String> services = [];

    if (data is List) {
      services = List<String>.from(data);
    } else if (data is String) {
      try {
        List<dynamic> decoded = json.decode(data);
        services = List<String>.from(decoded);
      } catch (e) {
        print('Error decoding services JSON string: $e');
      }
    }

    return services;
  }

  // ------------------ FILTER BUSINESSES ON SEARCH ------------------ //
  void _filterBusinesses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBusinesses = _businesses.where((business) {
        final name = business['name']?.toString().toLowerCase() ?? '';
        final type = business['type']?.toString().toLowerCase() ?? '';
        return name.contains(query) || type.contains(query);
      }).toList();
    });
  }

  // ------------------ FETCH ALL SLIDER IMAGES, THEN FILTER BY "Business" IN DART ------------------ //
  Future<void> _fetchSliderImages() async {
    // Replace with the actual URL to your show_slider.php
    final String showSliderUrl =
        'https://beingbaduga.com/being_baduga/show_slider.php';

    try {
      final response = await http.get(Uri.parse(showSliderUrl));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('Slider API Response: $data');

        if (data is Map<String, dynamic>) {
          if (data['status'] == 'success' && data['data'] is List) {
            final List<dynamic> sliderData = data['data'];

            // FILTER IN DART: Keep only those with "category_name" == "Business"
            final List<dynamic> businessSliderData = sliderData
                .where((item) => item['category_name'] == 'Business')
                .toList();

            setState(() {
              // Map to a List<String> of image URLs
              _sliderImages = businessSliderData
                  .map<String>((item) => item['image_url'].toString())
                  .toList();
              _isSliderLoading = false;
            });
          } else if (data['status'] == 'error' && data.containsKey('message')) {
            setState(() {
              _sliderError = data['message'];
              _isSliderLoading = false;
            });
          } else {
            setState(() {
              _sliderError = 'Unexpected slider response structure.';
              _isSliderLoading = false;
            });
          }
        } else {
          setState(() {
            _sliderError = 'Unexpected slider response format.';
            _isSliderLoading = false;
          });
        }
      } else {
        setState(() {
          _sliderError =
              'Failed to load slider images. Status Code: ${response.statusCode}';
          _isSliderLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _sliderError = 'An error occurred while fetching slider: $e';
        _isSliderLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------ BOTTOM NAV BAR TABS ------------------ //
  List<GButton> _buildTabs() {
    List<GButton> tabs = [
      const GButton(
        icon: Icons.home,
        text: 'Home',
      ),
      const GButton(
        icon: Icons.notifications,
        text: 'Notifications',
      ),
      const GButton(
        icon: Icons.person,
        text: 'Profile',
      ),
    ];

    // If packageId is even, add the Upload tab
    if (widget.packageId % 2 == 0) {
      tabs.insert(
        2,
        const GButton(
          icon: Icons.upload,
          text: 'Upload',
        ),
      );
    }

    return tabs;
  }

  // ------------------ NAVIGATION HANDLER ------------------ //
  Widget _getSelectedPage() {
    bool hasUpload = widget.packageId % 2 == 0;

    switch (_currentIndex) {
      case 0:
        return _buildHomePage(); // Home Page with Carousel and Search
      case 1:
        return BizNotificationPage(); // Notification Page
      case 2:
        if (hasUpload) {
          return BizUpload(user: widget.user);
        } else {
          return BizProfile(user: widget.user);
        }
      case 3:
        if (hasUpload) {
          return BizProfile(user: widget.user);
        } else {
          return _buildHomePage();
        }
      default:
        return _buildHomePage();
    }
  }

  // ------------------ HOME PAGE (CAROUSEL + SEARCH + LIST) ------------------ //
  Widget _buildHomePage() {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // ---- CAROUSEL SLIDER ---- //
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _isSliderLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : (_sliderError != null && _sliderError!.isNotEmpty)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _sliderError!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : CarouselSlider(
                        items: _sliderImages.map((imageUrl) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            // Wrap each image with InteractiveViewer
                            // for pinch-to-zoom on the same screen
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: InteractiveViewer(
                                // Optional: tweak these to suit your zoom preferences
                                panEnabled: true,
                                minScale: 1.0,
                                maxScale: 4.0,
                                clipBehavior: Clip.none,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 200.0,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          aspectRatio: 16 / 9,
                          initialPage: 0,
                        ),
                      ),
          ),

          // ---- SEARCH BAR ---- //
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a service provider...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      _filterBusinesses();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
          ),

          // ---- BUSINESS LIST ---- //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _errorMessage != null && _errorMessage!.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : _filteredBusinesses.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No service providers found.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredBusinesses.length,
                            itemBuilder: (context, index) {
                              final business = _filteredBusinesses[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BusinessDetails(business: business),
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 4,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      // ---- BUSINESS IMAGE ---- //
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                          left: Radius.circular(15.0),
                                        ),
                                        child: Image.network(
                                          business['photo'] ?? '',
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey[200],
                                            height: 100,
                                            width: 100,
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // ---- BUSINESS DETAILS ---- //
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Tappable Business Name
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _tappedTextColors[index] =
                                                        _tappedTextColors[
                                                                    index] ==
                                                                theme
                                                                    .primaryColor
                                                            ? Colors.black
                                                            : theme
                                                                .primaryColor;
                                                  });
                                                },
                                                child: Text(
                                                  business['name'] ??
                                                      'Business Name',
                                                  style: theme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: _tappedTextColors[
                                                            index] ??
                                                        theme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                business['type'] ??
                                                    'Business Type',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: theme.textTheme
                                                      .bodyMedium?.color
                                                      ?.withOpacity(0.7),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.email,
                                                    size: 16,
                                                    color: theme.primaryColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      business['email'] ??
                                                          'email@example.com',
                                                      style: theme
                                                          .textTheme.bodyMedium
                                                          ?.copyWith(
                                                        color:
                                                            theme.primaryColor,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: theme.primaryColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      business['address'] ??
                                                          'Address not available',
                                                      style: theme
                                                          .textTheme.bodyMedium
                                                          ?.copyWith(
                                                        color: theme.textTheme
                                                            .bodyMedium?.color
                                                            ?.withOpacity(0.7),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Display Services
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8.0,
                                                runSpacing: 4.0,
                                                children: (business['services']
                                                            as List<dynamic>?)
                                                        ?.map(
                                                            (service) =>
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4.0,
                                                                      horizontal:
                                                                          8.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: theme
                                                                        .primaryColor
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                  ),
                                                                  child: Text(
                                                                    service
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: theme
                                                                          .primaryColor,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ))
                                                        .toList() ??
                                                    [],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // ---- CALL ICON ---- //
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.phone,
                                            color: theme.primaryColor,
                                          ),
                                          onPressed: () async {
                                            final phone =
                                                business['phone'] ?? '';
                                            if (phone.isNotEmpty) {
                                              final Uri launchUri = Uri(
                                                scheme: 'tel',
                                                path: phone,
                                              );
                                              if (await canLaunch(
                                                  launchUri.toString())) {
                                                await launch(
                                                    launchUri.toString());
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Could not launch phone call',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // ------------------ BUILD SCAFFOLD ------------------ //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profiles'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _getSelectedPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFBE1744), // Bottom navigation bar color
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            color: Colors.white.withOpacity(0.7),
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.white.withOpacity(0.3),
            tabs: _buildTabs(),
            selectedIndex: _currentIndex,
            onTabChange: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
