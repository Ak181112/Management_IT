import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/dashboard_screen.dart';

class LoginButton extends StatelessWidget {
  final TextEditingController userController;
  final TextEditingController passwordController;

  const LoginButton({
    super.key,
    required this.userController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          final enteredUser = userController.text.trim();
          final enteredPass = passwordController.text;

          if (AuthService.verify(enteredUser, enteredPass)) {
            // Navigate to dashboard and remove login from stack
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User ID or password is wrong')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
