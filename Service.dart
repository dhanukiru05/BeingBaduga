// Service.dart

class Service {
  final int userServiceId;
  final int userId;
  final String paymentStatus;
  final String? createdDate;
  final int categoryId;
  final String categoryName;
  final int packageId;
  final String packageName;
  final String price;
  final int duration;
  final String serviceStartDate;
  final String serviceEndDate;
  final String packageStatus;

  Service({
    required this.userServiceId,
    required this.userId,
    required this.paymentStatus,
    this.createdDate,
    required this.categoryId,
    required this.categoryName,
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.duration,
    required this.serviceStartDate,
    required this.serviceEndDate,
    required this.packageStatus,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      userServiceId: json['user_service_id'] as int,
      userId: json['user_id'] as int,
      paymentStatus: json['payment_status'] as String,
      createdDate: json['created_date'] as String?,
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      packageId: json['package_id'] as int,
      packageName: json['package_name'] as String,
      price: json['price'] as String,
      duration: json['duration'] as int,
      serviceStartDate: json['service_start_date'] as String,
      serviceEndDate: json['service_end_date'] as String,
      packageStatus: json['package_status'] as String,
    );
  }
}