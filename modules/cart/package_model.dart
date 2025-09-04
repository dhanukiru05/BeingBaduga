// lib/modules/cart/package_model.dart

class Package {
  final int packageId;
  final String packageName;
  final String description;
  final double price;
  final String imageUrl;
  final int categoryId;
  final String categoryName; // New property added

  Package({
    required this.packageId,
    required this.packageName,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName, // Initialize in constructor
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;

    if (json['price'] != null) {
      if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        parsedPrice = double.tryParse(json['price']) ?? 0.0;
      } else {
        print('Unknown type for price: ${json['price'].runtimeType}');
      }
    } else {
      print('Price is null for package: ${json['package_name']}');
    }

    int parsedCategoryId = 0;
    if (json['category_id'] != null) {
      if (json['category_id'] is int) {
        parsedCategoryId = json['category_id'];
      } else if (json['category_id'] is String) {
        parsedCategoryId = int.tryParse(json['category_id']) ?? 0;
      } else {
        print(
            'Unknown type for category_id: ${json['category_id'].runtimeType}');
      }
    } else {
      print('category_id is null for package: ${json['package_name']}');
    }

    String parsedCategoryName = 'Unknown Category';
    if (json['category_name'] != null) {
      parsedCategoryName = json['category_name'];
    } else {
      print('category_name is null for package: ${json['package_name']}');
      // Optionally, map categoryId to categoryName if API doesn't provide it
      parsedCategoryName = _mapCategoryIdToName(parsedCategoryId);
    }

    return Package(
      packageId: json['package_id'] ?? -1,
      packageName: json['package_name'] ?? 'Unnamed Package',
      description: json['description'] ?? '',
      price: parsedPrice,
      imageUrl: json['image_url'] ?? '',
      categoryId: parsedCategoryId,
      categoryName: parsedCategoryName, // Assign parsedCategoryName
    );
  }

  // Optional: Method to map categoryId to categoryName locally
  static String _mapCategoryIdToName(int categoryId) {
    const Map<int, String> categoryMap = {
      1: 'Ebooks',
      2: 'Audiobooks',
      3: 'Magazines',
      4: 'Comics',
      // Add more mappings as needed
    };
    return categoryMap[categoryId] ?? 'Unknown Category';
  }
}
