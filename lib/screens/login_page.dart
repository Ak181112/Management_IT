import 'package:flutter/material.dart';
import '../widgets/login_form.dart'; // Import the main content widget

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: LoginForm(), // The content is delegated to LoginForm
        ),
      ),
    );
  }
}