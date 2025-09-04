// lib/pages/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:beingbaduga/modules/cart/package_model.dart';

class CheckoutPage extends StatelessWidget {
  final Map<int, Package> selectedPackages;
  final Function(int) onRemove; // Function to remove package by categoryId

  const CheckoutPage({
    Key? key,
    required this.selectedPackages,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define category names based on category_id
    final Map<int, String> categories = {
      1: 'Business',
      2: 'Matrimony',
      3: 'Ebook',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: selectedPackages.isEmpty
          ? Center(
              child: Text(
                'No packages selected.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: selectedPackages.entries.map((entry) {
                final categoryId = entry.key;
                final package = entry.value;
                final categoryName =
                    categories[categoryId] ?? 'Unknown Category';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            package.imageUrl,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 60,
                              width: 60,
                              color: Colors.grey[200],
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package.packageName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                package.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${package.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 6),
                            IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                // Remove the package from selection
                                onRemove(categoryId);
                                // Show a snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Removed ${package.packageName} from selection.'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: selectedPackages.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Implement your checkout logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Proceeding to payment...')),
                  );
                },
                child: Text('Proceed to Payment'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            )
          : null,
    );
  }
}
