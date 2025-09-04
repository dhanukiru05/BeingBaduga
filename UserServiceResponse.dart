// UserServiceResponse.dart

import 'package:beingbaduga/user_service.dart';

class UserServiceResponse {
  final List<Service> services;

  UserServiceResponse({required this.services});

  factory UserServiceResponse.fromJson(Map<String, dynamic> json) {
    var servicesJson = json['services'] as List<dynamic>;
    List<Service> servicesList = servicesJson
        .map((serviceJson) => Service.fromJson(serviceJson))
        .toList();

    return UserServiceResponse(
      services: servicesList,
    );
  }
}
