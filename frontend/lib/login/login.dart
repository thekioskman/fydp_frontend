import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import '../homepage.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});
    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    @override
    void initState() {
        super.initState();
        _checkLoginStatus();  // Check login status when LoginPage loads
    }

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    void _checkLoginStatus() async {
        final prefs = await SharedPreferences.getInstance();
        final storedEmail = prefs.getString('user_email');

        if (storedEmail != null) {
            // Navigate to HomePage automatically
            if (!mounted) return;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(user_email: storedEmail)),
            );
        }
    }


    void _login() async {
        if (_formKey.currentState!.validate()) {
            final email = _emailController.text;
            final password = _passwordController.text;
            final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

            // Simulate sending a request to the backend
            try {
                final response = await http.post(
                    Uri.parse('$apiUrl/login'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'username': email, 'password': password}),
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
                            MaterialPageRoute(builder: (context) => MainScreen()),
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

    void _signUp() {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  SignUpPage()),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Login Page'),
            ),
            body: Padding(
            padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                        }
                        return null;
                    },
              ),
                SizedBox(height: 16.0),
                TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                    } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                    }
                    return null;
                },
                ),
                SizedBox(height: 24.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        ElevatedButton(
                            onPressed: _login,
                            child: const Text('Login'),
                        ),
                        const SizedBox(width: 16.0), // Adjust this value for spacing
                        ElevatedButton(
                            onPressed: _signUp,
                            child: const Text('Sign Up'),
                        ),
                    ],
                 ), 
                const SizedBox(height: 16.0),
                TextButton(
                    onPressed: () {
                        // Handle "Forgot Password" logic
                        print('Forgot Password Pressed');
                    },
                    child: Text('Forgot Password?'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}