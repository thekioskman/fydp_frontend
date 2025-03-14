import 'package:flutter/material.dart';

import 'club.dart';

class ClubDetailPage extends StatelessWidget {
  final Club club;

  ClubDetailPage({required this.club});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(club.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(club.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(club.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Club Tag: ${club.clubTag}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}