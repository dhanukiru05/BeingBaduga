// To parse this JSON data, do
//
//     final checkCategoryResponse = checkCategoryResponseFromJson(jsonString);

import 'dart:convert';

CheckCategoryResponse checkCategoryResponseFromJson(String str) => CheckCategoryResponse.fromJson(json.decode(str));

String checkCategoryResponseToJson(CheckCategoryResponse data) => json.encode(data.toJson());

class CheckCategoryResponse {
  Consolidated consolidated;
  List<CheckCategoryModel> services;

  CheckCategoryResponse({
    required this.consolidated,
    required this.services,
  });

  factory CheckCategoryResponse.fromJson(Map<String, dynamic> json) => CheckCategoryResponse(
    consolidated: Consolidated.fromJson(json["consolidated"]),
    services: List<CheckCategoryModel>.from(json["services"].map((x) => CheckCategoryModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "consolidated": consolidated.toJson(),
    "services": List<dynamic>.from(services.map((x) => x.toJson())),
  };
}

class Consolidated {
  String business;
  String matrimony;
  String ebooks;

  Consolidated({
    required this.business,
    required this.matrimony,
    required this.ebooks,
  });

  factory Consolidated.fromJson(Map<String, dynamic> json) => Consolidated(
    business: json["business"],
    matrimony: json["matrimony"],
    ebooks: json["ebooks"],
  );

  Map<String, dynamic> toJson() => {
    "business": business,
    "matrimony": matrimony,
    "ebooks": ebooks,
  };
}

class CheckCategoryModel {
  int? userServiceId;
  int? userId;
  String? paymentStatus;
  String? createdDate;
  int? categoryId;
  String? categoryName;
  int? packageId;
  String? packageName;
  String? price;
  int? duration;
  String? serviceStartDate;
  String? serviceEndDate;
  String? packageStatus;

  CheckCategoryModel({
     this.userServiceId,
     this.userId,
     this.paymentStatus,
     this.createdDate,
     this.categoryId,
     this.categoryName,
     this.packageId,
     this.packageName,
     this.price,
     this.duration,
     this.serviceStartDate,
     this.serviceEndDate,
     this.packageStatus,
  });

  factory CheckCategoryModel.fromJson(Map<String, dynamic> json) => CheckCategoryModel(
    userServiceId: json["user_service_id"],
    userId: json["user_id"],
    paymentStatus: json["payment_status"],
    createdDate: json["created_date"],
    categoryId: json["category_id"],
    categoryName: json["category_name"],
    packageId: json["package_id"],
    packageName: json["package_name"],
    price: json["price"],
    duration: json["duration"],
    serviceStartDate:json["service_start_date"],
    serviceEndDate: json["service_end_date"],
    packageStatus: json["package_status"],
  );

  Map<String, dynamic> toJson() => {
    "user_service_id": userServiceId,
    "user_id": userId,
    "payment_status": paymentStatus,
    "created_date": createdDate,
    "category_id": categoryId,
    "category_name": categoryName,
    "package_id": packageId,
    "package_name": packageName,
    "price": price,
    "duration": duration,
    "service_start_date":serviceStartDate,
    "service_end_date": serviceEndDate,
    "package_status": packageStatus,
  };
}
