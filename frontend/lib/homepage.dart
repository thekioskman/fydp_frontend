import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "login/login.dart";

class HomePage extends StatelessWidget {
    const HomePage({super.key, required this.user_email});

    void _logout(BuildContext context) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_email'); // Remove stored email
        

        //not async UI dependent
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
        );
    }

    final String user_email;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            title: const Text('Home Page'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text("Welcome $user_email", style: TextStyle(fontSize: 24.0),),
                    const SizedBox(height: 20,),
                    ElevatedButton(onPressed: () => _logout(context), child: Text("Logout"))
                ],
            )
        ),
        
        );
    }
}