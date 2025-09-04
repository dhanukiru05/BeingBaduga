// lib/pages/Home.dart

import 'dart:convert';
import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/expired_page.dart';
import 'package:beingbaduga/modules/AUDIO/music.dart';
import 'package:beingbaduga/modules/about/about.dart';
import 'package:beingbaduga/modules/book/book.dart';
import 'package:beingbaduga/modules/business/business_page.dart';
import 'package:beingbaduga/modules/cart/cart.dart';
import 'package:beingbaduga/modules/demo/matri.dart';
import 'package:beingbaduga/modules/events/events.dart';
import 'package:beingbaduga/modules/locations/maps.dart';
import 'package:beingbaduga/modules/rtuals/rituals.dart';
import 'package:beingbaduga/not_available_page.dart';
import 'package:beingbaduga/notification.dart';
import 'package:beingbaduga/profile.dart';
import 'package:beingbaduga/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:beingbaduga/modules/about/contact.dart';

const Color primaryColor = Color(0xFFBE1744);
const double sliverAppBarHeight = 200.0;

class Home extends StatefulWidget {
  final User user;
  Home({required this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ScrollController _scrollController;
  double _welcomeOpacity = 1.0;

  int _currentIndex = 0;

  // Service statuses
  String businessStatus = 'Not Available';
  String matrimonyStatus = 'Not Available';
  String ebooksStatus = 'Not Available';

  // Package IDs
  int businessPackageId = 1;
  int matrimonyPackageId = 1;
  int ebooksPackageId = 1;

  // Dynamic tiles
  List<Map<String, dynamic>> tiles = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    fetchServiceStatuses();
    fetchTiles();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchServiceStatuses() async {
    const apiUrl = 'https://beingbaduga.com/being_baduga/check_categories.php';
    try {
      final resp = await http.post(
        Uri.parse(apiUrl),
        body: {'user_id': widget.user.id.toString()},
      );
      if (resp.statusCode == 200) {
        final jsonResponse = json.decode(resp.body);
        final userService = UserServiceResponse.fromJson(jsonResponse);
        for (var svc in userService.services) {
          switch (svc.categoryName.toLowerCase()) {
            case 'business':
              businessPackageId = svc.packageId;
              businessStatus = svc.packageStatus;
              break;
            case 'matrimony':
              matrimonyPackageId = svc.packageId;
              matrimonyStatus = svc.packageStatus;
              break;
            case 'ebooks':
              ebooksPackageId = svc.packageId;
              ebooksStatus = svc.packageStatus;
              break;
          }
        }
        setState(() {});
      } else {
        setState(() {
          errorMessage = 'Failed to load services (${resp.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading services: $e';
      });
    }
  }

  Future<void> fetchTiles() async {
    final url = Uri.parse('https://beingbaduga.com/being_baduga/get_tiles.php');
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['success'] == true) {
          setState(() {
            tiles = List<Map<String, dynamic>>.from(data['tiles']);
            isLoading = false;
          });
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Server error: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load tiles: $e';
        isLoading = false;
      });
    }
  }

  void _scrollListener() {
    final offset = _scrollController.offset;
    final opacity = (1.0 - (offset / 150.0)).clamp(0.0, 1.0);
    setState(() {
      _welcomeOpacity = opacity;
    });
  }

  Widget getDestination(String categoryKey, Widget dest, String featureName) {
    final statusMap = {
      'business': businessStatus,
      'matrimony': matrimonyStatus,
      'ebooks': ebooksStatus,
    };
    final status = statusMap[categoryKey.toLowerCase()] ?? '';
    if (status == 'Available') return dest;
    if (status == 'Expired')
      return ExpiredPage(featureName: featureName, user: widget.user);
    return NotAvailablePage(featureName: featureName, user: widget.user);
  }

  Widget _buildSquareTile(BuildContext ctx, Map<String, dynamic> tile) {
    final title = tile['title'] as String;
    final desc = tile['description'] as String;
    final imageUrl = tile['image_url'] as String;
    final isPaid = (tile['paid'] ?? 0) == 1;
    final categoryKey = tile['category_key'] as String?;
    Widget dest;
    switch (title) {
      case 'E-Books':
        dest = EBookPage(user: widget.user, packageId: ebooksPackageId);
        break;
      case 'Business':
        dest = BusinessPage(user: widget.user, packageId: businessPackageId);
        break;
      case 'Matrimony':
        dest = Matrimony(user: widget.user, packageId: matrimonyPackageId);
        break;
      case 'Music':
        dest = MusicPage(user: widget.user);
        break;
      case 'Festivals':
        dest = EventsPage();
        break;
      case 'Find Locations':
        dest = MapsPage();
        break;
      case 'About Us':
        dest = AboutUsPage();
        break;
      case 'Rituals':
        dest = RitualsPage();
        break;
      default:
        dest = Container();
    }

    return AspectRatio(
      aspectRatio: 0.8,
      child: Stack(children: [
        GestureDetector(
          onTap: () {
            final target = (isPaid && categoryKey != null)
                ? getDestination(categoryKey, dest, title)
                : dest;
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => target),
            );
          },
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
            child: Column(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (c, ch, prog) => prog == null
                        ? ch
                        : Center(child: CircularProgressIndicator()),
                    errorBuilder: (c, e, st) => Center(
                        child: Icon(Icons.error, size: 50, color: Colors.red)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(children: [
                  Text(title,
                      style: TextStyle(
                          color: Color(0xFFEC407A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  SizedBox(height: 4),
                  Text(desc,
                      style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 12),
                      textAlign: TextAlign.center),
                ]),
              ),
            ]),
          ),
        ),
        if (isPaid)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(8)),
              child: Text('Premium',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
      ]),
    );
  }

  Widget _buildHomeContent() {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage));

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: sliverAppBarHeight,
          pinned: true,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(50))),
          flexibleSpace: LayoutBuilder(
            builder: (c, bc) {
              final pct = ((bc.maxHeight - kToolbarHeight) /
                      (sliverAppBarHeight - kToolbarHeight))
                  .clamp(0.0, 1.0);
              return FlexibleSpaceBar(
                title: Opacity(
                  opacity: 1 - _welcomeOpacity,
                  child: Row(children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: DecorationImage(
                            image: NetworkImage(
                                'https://res.cloudinary.com/dordpmvpm/image/upload/v1724081028/vkpqmfbcwgxhlyogiglc.jpg'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Welcome, ${widget.user.name}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ]),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(50)),
                  ),
                  child: SafeArea(
                    child: Opacity(
                      opacity: _welcomeOpacity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100 * _welcomeOpacity,
                            height: 100 * _welcomeOpacity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 7,
                                    offset: Offset(0, 4))
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://res.cloudinary.com/dordpmvpm/image/upload/v1724081028/vkpqmfbcwgxhlyogiglc.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Welcome, ${widget.user.name}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20 * _welcomeOpacity,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85),
            delegate: SliverChildBuilderDelegate(
              (c, i) => _buildSquareTile(c, tiles[i]),
              childCount: tiles.length,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> get _tabs => [
        NotificationPagee(user: widget.user),
        ProfilePage(user: widget.user),
        ContactPage(),
        CartPage(user: widget.user),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? _buildHomeContent() : _tabs[_currentIndex - 1],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black26)],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            color: Colors.white70,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Colors.white24,
            tabs: [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.notifications, text: 'Alerts'),
              GButton(icon: Icons.person, text: 'Profile'),
              GButton(icon: Icons.contact_support, text: 'Contact'),
              GButton(icon: Icons.shopping_cart, text: 'Cart'),
            ],
            selectedIndex: _currentIndex,
            onTabChange: (i) {
              setState(() {
                _currentIndex = i;
                if (i == 0) {
                  isLoading = true;
                  fetchTiles();
                  fetchServiceStatuses();
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
