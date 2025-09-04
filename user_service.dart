// lib/models/user_service.dart

class Consolidated {
  final String business;
  final String matrimony;
  final String ebooks;

  Consolidated({
    required this.business,
    required this.matrimony,
    required this.ebooks,
  });

  factory Consolidated.fromJson(Map<String, dynamic> json) {
    return Consolidated(
      business: json['business'] ?? 'Not Available',
      matrimony: json['matrimony'] ?? 'Not Available',
      ebooks: json['ebooks'] ?? 'Not Available',
    );
  }
}

class Service {
  final int userServiceId;
  final int userId;
  final String paymentStatus;
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
      userServiceId: json['user_service_id'],
      userId: json['user_id'],
      paymentStatus: json['payment_status'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      packageId: json['package_id'],
      packageName: json['package_name'],
      price: json['price'],
      duration: json['duration'],
      serviceStartDate: json['service_start_date'] ?? '',
      serviceEndDate: json['service_end_date'] ?? '',
      packageStatus: json['package_status'],
    );
  }
}

class UserServiceResponse {
  final Consolidated consolidated;
  final List<Service> services;

  UserServiceResponse({
    required this.consolidated,
    required this.services,
  });

  factory UserServiceResponse.fromJson(Map<String, dynamic> json) {
    var servicesList = json['services'] as List<dynamic>? ?? [];
    List<Service> services =
        servicesList.map((i) => Service.fromJson(i)).toList();

    return UserServiceResponse(
      consolidated: Consolidated.fromJson(json['consolidated'] ?? {}),
      services: services,
    );
  }

  get packageId => null;
}
