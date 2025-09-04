import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PackagesPage extends StatefulWidget {
  final String moduleName;
  final int categoryId;

  PackagesPage({required this.moduleName, required this.categoryId});

  @override
  _PackagesPageState createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  late Future<List<Map<String, dynamic>>> _packages;

  @override
  void initState() {
    super.initState();
    _packages = fetchPackages(widget.categoryId);
  }

  Future<List<Map<String, dynamic>>> fetchPackages(int categoryId) async {
    final response = await http.get(
      Uri.parse(
          'https://beingbaduga.com/being_baduga/check_package.php?category_id=$categoryId'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['packages'] != null) {
        final List<dynamic> packageList = responseData['packages'];
        return packageList.map((package) {
          return {
            'packageId': package['package_id'],
            'packageName': package['package_name'],
            'price': double.tryParse(package['price'].toString()) ?? 0.0,
            'duration': package['duration'] ?? 0,
            'description': package['description'] ?? 'No description available',
            'imageUrl': package['image_url'] ?? '', // Ensure non-null String
          };
        }).toList();
      } else {
        // Handle case when 'packages' is null
        return [];
      }
    } else {
      throw Exception('Failed to load packages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Packages',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _packages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Oh no! It seems you haven\'t registered for ${widget.moduleName} yet.',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please check the packages below to get access to premium content!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final packages = snapshot.data!;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ListView.builder(
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return PackageCard(
                  name: package['packageName'],
                  price: package['price'],
                  duration: package['duration'],
                  description: package['description'],
                  imageUrl: package['imageUrl'] ?? '', // Ensure non-null String
                  onPurchase: () {
                    _showPurchaseDialog(
                      context,
                      package['packageName'],
                      widget.moduleName,
                      package['price'],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, String packageName,
      String moduleName, double price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Purchase',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Do you want to purchase the "$packageName" for ₹${price.toStringAsFixed(2)} to access "$moduleName"?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[700]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchase Successful!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushNamed(context, '/${widget.moduleName}');
              },
            ),
          ],
        );
      },
    );
  }
}

class PackageCard extends StatelessWidget {
  final String name;
  final double price;
  final int duration;
  final String description;
  final String imageUrl; // Non-nullable String
  final VoidCallback onPurchase;

  PackageCard({
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.imageUrl, // Keep as required and non-nullable
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).hintColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Card(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.network(
                imageUrl.isNotEmpty
                    ? imageUrl
                    : 'https://via.placeholder.com/400', // Default placeholder
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Duration: $duration days',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onPurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Purchase',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
