// lib/services/user_service.dart

import 'dart:convert';
import 'package:beingbaduga/user_service.dart';
import 'package:http/http.dart' as http;

class UserService {
  // Singleton pattern (optional but recommended)
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  // Base URL of your API
  final String _baseUrl = 'https://beingbaduga.com/being_baduga/';

  // Fetch User Service Data
  Future<UserServiceResponse?> fetchUserServiceData(int userId) async {
    final url = Uri.parse('${_baseUrl}check_categories.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return UserServiceResponse.fromJson(responseBody);
      } else {
        print('Server error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('An error occurred: $e');
      return null;
    }
  }

  // Update User Profile (if needed)
  Future<bool> updateUserProfile(Map<String, dynamic> updatedData) async {
    final url = Uri.parse('${_baseUrl}update_profile.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['success'] ?? false;
      } else {
        print('Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('An error occurred: $e');
      return false;
    }
  }
}
