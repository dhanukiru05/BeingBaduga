// matrimony.dart

import 'dart:convert';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/modules/matermoney/matri_upload.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;

import 'member_details.dart';
import 'notification_page.dart';
import 'profile_page.dart';

class Matrimony extends StatefulWidget {
  final User user;
  final int packageId; // Added packageId

  const Matrimony({
    Key? key,
    required this.user,
    required this.packageId,
  }) : super(key: key);

  @override
  _MatrimonyState createState() => _MatrimonyState();
}

class _MatrimonyState extends State<Matrimony> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];

  // --- Slider-related fields ---
  List<String> _sliderImages = [];
  bool _isSliderLoading = true;
  String? _sliderError;

  // Initialize empty lists for titles, pages, and nav tabs
  late List<String> _titles;
  late List<Widget> _pages;
  late List<GButton> _navTabs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Fetch the slider images first
    _fetchSliderImages();
    // Then fetch members
    _fetchMembers();
    // Initialize bottom tabs
    _initializeTabs();
  }

  // ------------------ INITIALIZE TABS DYNAMICALLY ------------------ //
  void _initializeTabs() {
    // Check if packageId is even (for Upload tab)
    bool includeUploadTab = widget.packageId % 2 == 0;

    _titles = [
      'Find Your Partner',
      'Notifications',
      if (includeUploadTab) 'Upload',
      'Profile',
    ];

    _pages = [
      HomePage(
        members: _members,
        carouselImages: _sliderImages, // pass the dynamic slider images here
        onRefresh: _fetchMembers,
        currentUser: widget.user.toJson(),
      ),
      NotificationPage(user: widget.user),
      if (includeUploadTab)
        MatriUpload(user: widget.user, packageId: widget.packageId),
      MatriProfile(user: widget.user, packageId: widget.packageId),
    ];

    _navTabs = [
      GButton(icon: Icons.home, text: 'Home'),
      GButton(icon: Icons.notifications, text: 'Notifications'),
      if (includeUploadTab) GButton(icon: Icons.upload, text: 'Upload'),
      GButton(icon: Icons.person, text: 'Profile'),
    ];
  }

  @override
  void didUpdateWidget(covariant Matrimony oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageId != widget.packageId) {
      _initializeTabs(); // Re-initialize tabs if packageId changes
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ------------------ HANDLE APP LIFECYCLE ------------------ //
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchMembers();
    }
  }

  // ------------------ FETCH SLIDER IMAGES (CATEGORY = "Business") ------------------ //
  Future<void> _fetchSliderImages() async {
    // Adjust if needed for your actual show_slider.php path
    const String sliderApiUrl =
        'https://beingbaduga.com/being_baduga/show_slider.php';

    try {
      final response = await http.get(Uri.parse(sliderApiUrl));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['status'] == 'success' && data['data'] is List) {
            final List<dynamic> allSliderData = data['data'];
            // Filter by category_name == "Business"
            final List<dynamic> businessSliderData = allSliderData
                .where((item) => item['category_name'] == 'Matrimony')
                .toList();

            setState(() {
              _sliderImages = businessSliderData
                  .map<String>((item) => item['image_url'].toString())
                  .toList();
              _isSliderLoading = false;
              _sliderError = null;
            });

            // Rebuild the pages with updated slider images
            _initializeTabs();
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
        _sliderError = 'An error occurred: $e';
        _isSliderLoading = false;
      });
    }
  }

  // ------------------ FETCH MATRIMONY MEMBERS ------------------ //
  Future<void> _fetchMembers() async {
    const String apiUrl = 'https://beingbaduga.com/being_baduga/matri_get.php';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      // Debug info
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<Map<String, dynamic>> fetchedMembers = [];

        // Handle different possible response structures
        if (decoded is List) {
          // JSON Array
          for (var item in decoded) {
            if (item is Map<String, dynamic>) {
              fetchedMembers.add(item);
            } else {
              print('Unexpected item type in List: ${item.runtimeType}');
            }
          }
        } else if (decoded is Map<String, dynamic>) {
          // JSON Object with Nested Array
          if (decoded.containsKey('data') && decoded['data'] is List) {
            for (var item in decoded['data']) {
              if (item is Map<String, dynamic>) {
                fetchedMembers.add(item);
              } else {
                print('Unexpected item type in data List: ${item.runtimeType}');
              }
            }
          } else if (decoded.containsKey('members') &&
              decoded['members'] is List) {
            // Alternate key if 'data' not used
            for (var item in decoded['members']) {
              if (item is Map<String, dynamic>) {
                fetchedMembers.add(item);
              } else {
                print(
                    'Unexpected item type in members List: ${item.runtimeType}');
              }
            }
          } else {
            // Error or unexpected structure
            String errorMessage = decoded['message'] ?? 'Unknown error';
            throw Exception('API Error: $errorMessage');
          }
        } else {
          // Unexpected top-level JSON structure
          throw Exception('Unexpected JSON structure: ${decoded.runtimeType}');
        }

        setState(() {
          _members = fetchedMembers;
          _isLoading = false;
        });

        // Re-initialize pages now that we have members
        _initializeTabs();
      } else {
        // Non-200 HTTP response
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching members: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching members: $e')),
      );
    }
  }

  // ------------------ BUILD WIDGET TREE ------------------ //
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: theme.primaryColor,
              title: Text(
                _titles[_currentIndex],
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_pages.isNotEmpty
              ? _pages[_currentIndex]
              : Center(child: Text("No data available"))),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFBE1744),
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
            tabs: _navTabs,
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

// ------------------ HOME PAGE ------------------ //
class HomePage extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final List<String> carouselImages;
  final Future<void> Function() onRefresh;
  final Map<String, dynamic> currentUser;

  const HomePage({
    Key? key,
    required this.members,
    required this.carouselImages,
    required this.onRefresh,
    required this.currentUser,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> _displayedMembers;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayedMembers = widget.members;
    _searchController.addListener(_filterMembers);
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.members != widget.members) {
      _displayedMembers = widget.members;
      _filterMembers();
    }
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedMembers = widget.members;
      } else {
        _displayedMembers = widget.members.where((member) {
          final fullName = member['full_name'];
          if (fullName == null) return false;
          return fullName.toString().toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ----- DYNAMIC CAROUSEL SLIDER ----- //
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  aspectRatio: 16 / 9,
                  initialPage: 0,
                ),
                items: widget.carouselImages.map((imageUrl) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ----- SEARCH BAR ----- //
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.hintColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search profiles',
                          hintStyle: GoogleFonts.montserrat(
                            color: theme.hintColor,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.montserrat(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: theme.hintColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            // ----- MEMBER LIST ----- //
            _displayedMembers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      "Be the first to post the profile and get listed!",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _displayedMembers.length,
                    itemBuilder: (context, index) {
                      final member = _displayedMembers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemberDetails(
                                  member: member,
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 3,
                            color: theme.primaryColor.withOpacity(0.9),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Profile Image with Placeholder
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: CachedNetworkImage(
                                      imageUrl: member['profile_photo_url']
                                              as String? ??
                                          'https://via.placeholder.com/80',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),

                                  // Profile Information
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member['full_name'] as String? ??
                                              'Unknown Name',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Text(
                                              'Age: ${member['age'] ?? 'N/A'}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(width: 16.0),
                                            Text(
                                              'Gender: ${member['gender'] ?? 'N/A'}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          'Occupation: ${member['occupation'] ?? 'N/A'}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
