import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status when LoginPage loads
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

    final response = await http.get(Uri.parse('$apiUrl/user/$userId'));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        if (!mounted) return;
        PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(name: "MainScreen"),
          screen: MainScreen(),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      } else {
        await prefs.clear();
      }
    } else {
      await prefs.clear();
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

      try {
        final response = await http.post(
          Uri.parse('$apiUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}), // ✅ Send username instead of email
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          if (responseBody['success'] == true) {
            final userId = responseBody["user_id"];
            final firstName = responseBody["first_name"];
            final lastName = responseBody["last_name"];

            // Save credentials after successful login
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', username); // ✅ Save username instead of email
            await prefs.setString('user_id', userId.toString());
            await prefs.setString("first_name", firstName);
            await prefs.setString("last_name", lastName);

            if (!mounted) return;
            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
              context,
              settings: RouteSettings(name: "MainScreen"),
              screen: MainScreen(),
              withNavBar: true,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseBody['message'] ?? 'Login failed')),
            );
          }
        } else {
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody["detail"] ?? "Server Error")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    }
  }

  void _signUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
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
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
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
