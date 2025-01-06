import 'package:flutter/material.dart';
import '../homepage.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
    final String title;
    const LoginPage({super.key, required this.title});
    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    void _login() {
        if (_formKey.currentState!.validate()) {
            final email = _emailController.text;
            final password = _passwordController.text;
            // Simulate a login process (this is where you would validate credentials)
            if (email == "user@example.com" && password == "password123") {
                // Navigate to the HomePage on successful login
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(user_email: email)),
                );
            } else {
                // Show an error message
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid email or password')),
                );
            }
        }
    }

    void _signUp() {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpPage()),
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