import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUpPage extends StatefulWidget {
    const SignUpPage({super.key});

    @override
    _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    @override
    void dispose() {
        _nameController.dispose();
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    void _signUp() async {
        if (_formKey.currentState!.validate()) {
            final name = _nameController.text;
            final email = _emailController.text;
            final password = _passwordController.text;
            final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/dancemeet'; //env for we dont need to change all the endpoints when we shift to prod

            try {
                final response = await http.post(
                    Uri.parse('$apiUrl/signup'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                        'name': name,
                        'email': email,
                        'password': password,
                    }),
                );

                if (!mounted) return;

                if (response.statusCode == 201) {
                    // Successfully signed up
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sign Up Successful!')),
                    );
                    Navigator.pop(context); // Navigate back to the login page
                    } else {
                    final responseBody = jsonDecode(response.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(responseBody['message'] ?? 'Sign Up Failed')),
                    );
                }
            } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Network error: $e')),
                );
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            title: const Text('Sign Up'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                    }
                    return null;
                    },
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                    }
                    return null;
                    },
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                    }
                    if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                    }
                    return null;
                    },
                ),
                const SizedBox(height: 32),
                Center(
                    child: ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                    ),
                ),
                ],
            ),
            ),
        ),
        );
    }
}