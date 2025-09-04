// lib/models/user_model.dart

import 'dart:convert';

User userResponseFromJson(String str) => User.fromJson(json.decode(str));

String userResponseToJson(User data) => json.encode(data.toJson());

class User {
  final int id; // Unique identifier for the user
  String name;
  String email;
  String phone;
  String dob;
  int age;
  String gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.age,
    required this.gender,
  });

  /// Factory method to create a User instance from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0, // Ensure 'id' is present
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      age: int.tryParse(json['age'].toString()) ?? 0,
      gender: json['gender'] ?? '',
    );
  }

  get packageId => null;

  /// Method to convert a User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'age': age,
      'gender': gender,
    };
  }
}
