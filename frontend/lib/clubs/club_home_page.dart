import 'package:flutter/material.dart';
import 'club.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'create_event.dart';

class ClubHomePage extends StatelessWidget {
  final Club club;

  ClubHomePage({required this.club});

  void _createEvent(BuildContext context) async {
    PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
      context,
      settings: RouteSettings(name: "CreateEventScreen"),
      screen: CreateEventPage(),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

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
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _createEvent(context), // Pass context here
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}