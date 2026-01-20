import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Static user data to hold session info
  static String? userId; // 'code' from backend
  static String? dbId; // MongoDB _id
  static String? token;
  static String firstName = '';
  static String lastName = '';
  static String role = '';
  static String branchId = '';
  static String branchName = '';
  static String? avatarPath;
  static String email = '';
  static String mobile = '';

  static Future<bool> login(
    String user,
    String pass, {
    String role = 'manager',
  }) async {
    debugPrint('Attempting login for: $user');
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.authLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': user, // Backend expects 'username' (email or userId)
          'password': pass,
          'role': role, // Backend expects 'role'
        }),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'];

          userId = data['code'];
          dbId = data['id']; // Stored as 'id' in backend response
          token = data['token']; // The token is inside the data object
          firstName = data['name'] ?? '';
          AuthService.role = data['role'] ?? ''; // Use static member
          branchId = data['branchId'] ?? '';
          branchName = data['branchName'] ?? '';
          email = data['email'] ?? '';
          mobile = data['phone'] ?? '';

          if (token != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token!);
            await prefs.setString('user_role', AuthService.role);
            await prefs.setString('user_branch_id', branchId);
            debugPrint('Token saved to storage');
          }

          return true;
        }
      }

      debugPrint('Login failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('CRITICAL LOGIN ERROR: $e');
      return false;
    }
  }

  static Future<bool> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/change-password');

      if (dbId == null) {
        debugPrint('Error: User DB ID not found');
        return false;
      }

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': dbId,
          'role': role == 'Manager' ? 'manager' : 'field_visitor',
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Change Password Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Change Password Error: $e');
      return false;
    }
  }

  static Future<void> resetPassword(String newPassword) async {
    debugPrint('Mock Password Reset: $newPassword');
  }

  static String generateOtp() {
    return '1234';
  }

  static bool verifyOtp(String enteredOtp) {
    return enteredOtp == '1234';
  }

  static void clearOtp() {}

  static Map<String, String> getProfile() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'avatarPath': avatarPath ?? '',
      'role': role,
      'branch': branchName,
    };
  }

  static void updateProfile({
    String? newFirstName,
    String? newLastName,
    String? newDob,
    String? newEmail,
    String? newMobile,
    String? newAvatarPath,
  }) {
    if (newFirstName != null) firstName = newFirstName;
    if (newLastName != null) lastName = newLastName;
    if (newEmail != null) email = newEmail;
    if (newMobile != null) mobile = newMobile;
    if (newAvatarPath != null) avatarPath = newAvatarPath;
  }

  static Future<void> logout() async {
    userId = null;
    dbId = null;
    token = null;
    firstName = '';
    role = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
