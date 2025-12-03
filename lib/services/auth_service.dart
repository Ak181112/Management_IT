import 'dart:math';

class AuthService {
  static String userId = 'KA0001';
  static String password = '1234';
  static String? _generatedOtp;

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
}
