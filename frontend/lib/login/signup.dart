import 'package:flutter/material.dart';
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Page'),
      ),
      body: const Center(
        child: Text(
          'Sign Up Form Goes Here',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}