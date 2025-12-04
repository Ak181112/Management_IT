import 'dart:math';

class AuthService {
  static String userId = 'KA0001';
  static String password = '1234';
  static String? _generatedOtp;
  // Simple in-memory profile data
  static String firstName = 'John';
  static String lastName = 'Doe';
  static String dob = '1990-01-01';
  static String email = 'john.doe@example.com';
  static String mobile = '+1234567890';
  static String? avatarPath;

  static bool verify(String user, String pass) {
    return user == userId && pass == password;
  }

  static void changePassword(String newPassword) {
    password = newPassword;
  }

  static String generateOtp() {
    _generatedOtp = Random().nextInt(10000).toString().padLeft(4, '0');
    return _generatedOtp!;
  }

  static bool verifyOtp(String enteredOtp) {
    return enteredOtp == _generatedOtp;
  }

  static void clearOtp() {
    _generatedOtp = null;
  }

  static Map<String, String> getProfile() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'email': email,
      'mobile': mobile,
      'avatarPath': avatarPath ?? '',
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
    if (newDob != null) dob = newDob;
    if (newEmail != null) email = newEmail;
    if (newMobile != null) mobile = newMobile;
    if (newAvatarPath != null) avatarPath = newAvatarPath;
  }

  static void logout() {
    // For this simple app, clear any session-related data if needed.
    // Navigation is handled by UI code (push to login page).
  }
}
