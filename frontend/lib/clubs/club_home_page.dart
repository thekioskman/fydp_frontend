import 'package:flutter/material.dart';
import 'club.dart';

class ClubHomePage extends StatelessWidget {
  final Club club;

  ClubHomePage({required this.club});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(club.name ?? 'Club Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Club Name: ${club.name}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Club Tag: #${club.clubTag}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              "Description: ${club.description}",
              style: TextStyle(fontSize: 16),
            ),
            // Add more details or functionality as needed
          ],
        ),
      ),
    );
  }
}