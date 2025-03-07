import 'package:flutter/material.dart';

class ClubHomePage extends StatelessWidget {
  final Map<String, dynamic> club;

  ClubHomePage({required this.club});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(club['name'] ?? 'Club Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Club Name: ${club['name']}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Club Tag: #${club['club_tag']}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              "Description: ${club['description']}",
              style: TextStyle(fontSize: 16),
            ),
            // Add more details or functionality as needed
          ],
        ),
      ),
    );
  }
}