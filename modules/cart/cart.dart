// lib/pages/cart_page.dart

import 'dart:convert';
import 'package:beingbaduga/User_Model.dart';
import 'package:beingbaduga/modules/cart/package_model.dart';
import 'package:beingbaduga/modules/cart/purchase_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class CartPage extends StatefulWidget {
  final User user;

  const CartPage({Key? key, required this.user}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = false;
  List<Package> _packages = [];
  String _errorMessage = '';
  List<Package> _selectedPackages = [];

  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  final Map<int, String> _categories = {
    1: 'Business',
    2: 'Matrimony',
    3: 'Ebook',
  };

  Future<void> _fetchPackages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url =
        Uri.parse('https://beingbaduga.com/being_baduga/show_packages.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> packagesJson = data['packages'];
        final packages =
            packagesJson.map((json) => Package.fromJson(json)).toList();

        setState(() {
          _packages = packages;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load packages. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectPackage(Package package) {
    setState(() {
      // Check if a package from the same category is already selected
      final existingPackage = _selectedPackages.firstWhere(
          (p) => p.categoryId == package.categoryId,
          orElse: () => Package(
                packageId: -1,
                packageName: '',
                description: '',
                price: 0.0,
                categoryId: -1,
                imageUrl: '',
                categoryName: '',
              ));

      if (existingPackage.packageId != -1) {
        _selectedPackages.remove(existingPackage);
      }

      if (_selectedPackages.contains(package)) {
        _selectedPackages.remove(package);
      } else {
        _selectedPackages.add(package);
        if (_selectedPackages.length == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _draggableController.animateTo(
              0.4,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      }

      if (_selectedPackages.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _draggableController.animateTo(
            0.1,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_selectedPackages.contains(package)
            ? 'Added ${package.packageName} to cart.'
            : 'Removed ${package.packageName} from cart.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Map<int, List<Package>> get _groupedPackages {
    Map<int, List<Package>> grouped = {};
    for (var package in _packages) {
      if (grouped.containsKey(package.categoryId)) {
        grouped[package.categoryId]!.add(package);
      } else {
        grouped[package.categoryId] = [package];
      }
    }
    return grouped;
  }

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Package'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (_selectedPackages.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Center(
                        child: Text(
                          '${_selectedPackages.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () {
              if (_selectedPackages.isNotEmpty) {
                _draggableController.animateTo(
                  0.4,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _packages.isEmpty
                      ? Center(child: Text('No packages available.'))
                      : ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: _categories.entries.map((entry) {
                            final categoryId = entry.key;
                            final categoryName = entry.value;
                            final packages = _groupedPackages[categoryId] ?? [];

                            if (packages.isEmpty) return SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    categoryName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                ...packages.map((package) {
                                  double price = package.price;

                                  final isSelected =
                                      _selectedPackages.contains(package);

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                  imageUrl: package.imageUrl,
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    height: 80,
                                                    width: 80,
                                                    color: Colors.grey[200],
                                                    child: Icon(Icons.image,
                                                        color:
                                                            Colors.grey[400]),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    height: 80,
                                                    width: 80,
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                        Icons.broken_image,
                                                        color:
                                                            Colors.grey[400]),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      package.packageName,
                                                      style: theme
                                                          .textTheme.titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      package.description,
                                                      style: theme
                                                          .textTheme.bodyMedium
                                                          ?.copyWith(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '₹${price.toStringAsFixed(2)}',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color: theme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _selectPackage(package),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  backgroundColor:
                                                      theme.primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                                child: Text(
                                                  isSelected
                                                      ? 'Remove'
                                                      : 'Select',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                SizedBox(height: 20),
                              ],
                            );
                          }).toList(),
                        ),
          // Sliding Checkout Panel
          if (_selectedPackages.isNotEmpty)
            DraggableScrollableSheet(
              controller: _draggableController,
              initialChildSize: 0.4,
              minChildSize: 0.1,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black26,
                        offset: Offset(0, -2),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _selectedPackages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedPackages.length) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Divider(),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total:',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          '₹${_calculateTotalPrice().toStringAsFixed(2)}',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _navigateToConfirmation(),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 15),
                                        backgroundColor: theme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        'Confirm Purchase',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              );
                            }

                            final package = _selectedPackages[index];
                            double price = package.price;
                            String categoryName =
                                _categories[package.categoryId] ?? '';

                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: package.imageUrl,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 50,
                                    width: 50,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image,
                                        color: Colors.grey[400]),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 50,
                                    width: 50,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                              title: Text(package.packageName),
                              subtitle: Text(categoryName),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('₹${price.toStringAsFixed(2)}'),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle,
                                        color: Colors.redAccent),
                                    onPressed: () => _selectPackage(package),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  double _calculateTotalPrice() {
    double total = 0.0;
    for (var package in _selectedPackages) {
      total += package.price;
    }
    return total;
  }

  void _navigateToConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseConfirmationPage(
          selectedPackages: _selectedPackages,
          user: widget.user,
        ),
      ),
    ).then((_) {
      // Optionally, clear the cart after returning from the confirmation page
      setState(() {
        _selectedPackages.clear();
      });
      _draggableController.animateTo(
        0.1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
}
