import 'package:flutter/material.dart';
import 'package:frontend/posts/all_posts_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
    @override
    _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    void  _signUp() async {
        if (_formKey.currentState!.validate()) {
            // Perform sign-up logic here
            String email = _emailController.text;
            String password = _passwordController.text;

            // You can add your sign-up logic here, such as calling an API
            final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

            try {
                final response = await http.post(
                    Uri.parse('$apiUrl/register'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'user_name': email, 'password': password}),
                );
                if (!mounted) return; //maybe the user closed the app while this was running

                if (response.statusCode == 200) {
                    final responseBody = jsonDecode(response.body);
                    if (responseBody['success'] == true) {
                        // Navigate to HomePage on successful login

                        //Save credentials one succesful login
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('user_email', email);

                        if (!mounted) return;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => PostsPage()),
                        );
                    } else {
                        // Show error message from backend
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(responseBody['message'] ?? 'Login failed')),
                        );
                    }
                } else {
                    // Handle server errors
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Server error. Please try again later.')),
                    );
                }
            } catch (e) {
                // Handle network errors
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
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}