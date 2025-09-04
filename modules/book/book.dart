import 'dart:convert';
import 'dart:io';

import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/homepage.dart';
import 'package:beingbaduga/modules/about/contact.dart';
import 'package:beingbaduga/modules/book/ebooknoti.dart';
import 'package:beingbaduga/modules/book/ebookprofile.dart';
import 'package:beingbaduga/modules/book/ebookupload.dart';
import 'package:beingbaduga/modules/book/pdfviwer.dart';
import 'package:beingbaduga/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';

class EBookPage extends StatefulWidget {
  final User user;
  final int packageId;

  EBookPage({required this.user, required this.packageId});

  @override
  _EBookPageState createState() => _EBookPageState();
}

class _EBookPageState extends State<EBookPage> {
  // ------------------ BOOK DATA ------------------ //
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> filteredBooks = [];
  final TextEditingController searchController = TextEditingController();

  // ------------------ SLIDER DATA ------------------ //
  List<String> _sliderImages = [];
  bool _isSliderLoading = true;
  String? _sliderError;

  // ------------------ NAVIGATION ------------------ //
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch both the slider images and the book list
    _fetchSliderImages();
    _fetchBooks();

    // Listen for search changes
    searchController.addListener(() {
      _searchBooks(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ------------------ FETCH SLIDER IMAGES (category_name = "Ebook") ------------------ //
  Future<void> _fetchSliderImages() async {
    const String sliderApiUrl =
        'https://beingbaduga.com/being_baduga/show_slider.php';
    try {
      final response = await http.get(Uri.parse(sliderApiUrl));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['status'] == 'success' && data['data'] is List) {
            final List<dynamic> allSliderData = data['data'];
            // Filter for category_name = "Ebook"
            final List<dynamic> ebookSliderData = allSliderData
                .where((item) => item['category_name'] == 'Ebook')
                .toList();

            setState(() {
              _sliderImages = ebookSliderData
                  .map<String>((item) => item['image_url'].toString())
                  .toList();
              _isSliderLoading = false;
              _sliderError = null;
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
        _sliderError = 'Error fetching slider images: $e';
        _isSliderLoading = false;
      });
    }
  }

  // ------------------ FETCH E-BOOKS ------------------ //
  Future<void> _fetchBooks() async {
    try {
      final response = await http
          .get(Uri.parse('https://beingbaduga.com/being_baduga/ebook.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'success') {
          setState(() {
            books = (data['data'] as List<dynamic>)
                .map((item) => item as Map<String, dynamic>)
                // Filter out books where status is 'off'
                .where((book) => book['status'] != 'off')
                .toList();
            filteredBooks = books; // Initialize filteredBooks
          });
        } else {
          print('API Error: ${data['message']}');
          // Optionally, show a Snackbar or other UI feedback
        }
      } else {
        print('Network Error: ${response.statusCode}');
        // Optionally, show a Snackbar or other UI feedback
      }
    } catch (e) {
      print('Error fetching books: $e');
      // Optionally, show a Snackbar or other UI feedback
    }
  }

  // ------------------ SEARCH BOOKS ------------------ //
  void _searchBooks(String query) {
    setState(() {
      filteredBooks = books
          .where((book) =>
              ((book['title'] ?? '') as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              ((book['author'] ?? '') as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  // ------------------ OPEN SELECTED PDF ------------------ //
  void _openPDF(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(
          currentIndex: index,
          books: books, // Pass the entire books list
        ),
      ),
    );
  }

  // ------------------ BUILD UI ------------------ //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ebook"),
        backgroundColor: const Color(0xFFBE1744),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to home.dart
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(user: widget.user),
              ),
            );
          },
        ),
        // SEARCH BAR as part of the AppBar's bottom
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search books by title or author...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchController.clear();
                    _searchBooks(''); // Reset the search results
                    FocusScope.of(context).unfocus();
                  },
                ),
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
      body: _getSelectedPage(),
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

  // ------------------ BOTTOM NAV TABS ------------------ //
  List<GButton> _buildTabs() {
    List<GButton> tabs = [
      const GButton(icon: Icons.book, text: 'E-Books'),
      const GButton(icon: Icons.notifications, text: 'Notifications'),
      const GButton(icon: Icons.person, text: 'Profile'),
    ];

    // If packageId is even, add the Upload tab
    if (widget.packageId % 2 == 0) {
      tabs.insert(
        2,
        const GButton(icon: Icons.upload, text: 'Upload'),
      );
    }

    return tabs;
  }

  // ------------------ HANDLE SELECTED PAGE ------------------ //
  Widget _getSelectedPage() {
    // If packageId is even => has an Upload tab
    bool hasUpload = widget.packageId % 2 == 0;

    switch (_currentIndex) {
      case 0:
        return _buildEbookHome(); // Show slider + grid
      case 1:
        return NotificationPagee(user: widget.user);
      case 2:
        if (hasUpload) {
          return EbookUpload(user: widget.user);
        } else {
          return EbookProfile(user: widget.user);
        }
      case 3:
        // If we reached index 3, that means hasUpload = true
        return EbookProfile(user: widget.user);
      default:
        return _buildEbookHome();
    }
  }

  // ------------------ BUILD THE HOME CONTENT (SLIDER + EBOOK GRID) ------------------ //
  Widget _buildEbookHome() {
    // We’ll show a column with a slider on top, then the book grid
    return SingleChildScrollView(
      child: Column(
        children: [
          // ---- SLIDER SECTION ---- //
          if (_isSliderLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )
          else if (_sliderError != null && _sliderError!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _sliderError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (_sliderImages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No slider images found for Ebook."),
            )
          else
            CarouselSlider(
              items: _sliderImages.map((imageUrl) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
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

          // ---- GRID OF EBOOKS ---- //
          _buildBookGrid(),
        ],
      ),
    );
  }

  // ------------------ E-BOOK GRID ------------------ //
  Widget _buildBookGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredBooks.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two tiles per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7, // Adjust for better fit
        ),
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          return GestureDetector(
            onTap: () => _openPDF(context, index),
            child: FutureBuilder<File?>(
              future: _getPdfPreview(book['pdf_url'] as String),
              builder: (context, snapshot) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child:
                              snapshot.connectionState == ConnectionState.done
                                  ? (snapshot.hasData
                                      ? PDFView(
                                          filePath: snapshot.data!.path,
                                          enableSwipe: false,
                                          swipeHorizontal: false,
                                          autoSpacing: false,
                                          pageFling: false,
                                        )
                                      : (book['cover_image_url'] != null
                                          ? Image.network(
                                              book['cover_image_url'] as String,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              'https://via.placeholder.com/150',
                                              fit: BoxFit.cover,
                                            )))
                                  : const Center(
                                      child: CircularProgressIndicator()),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (book['title'] ?? 'Unknown Title') as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ((book['author'] ?? 'Unknown') as String),
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ------------------ DOWNLOAD PDF PREVIEW ------------------ //
  Future<File?> _getPdfPreview(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp_preview_${url.hashCode}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      print('Error loading PDF preview: $e');
      return null;
    }
  }
}
