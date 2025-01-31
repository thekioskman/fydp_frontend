import 'package:flutter/material.dart';
import 'pages/profiletop.dart';

class ProfileMainPage extends StatefulWidget {
  const ProfileMainPage({super.key});

  @override
  _ProfileMainPageState createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
    final String profilePicUrl = 'https://newprofilepic.photo-cdn.net//assets/images/article/profile.jpg?90af0c8';
    final String firstName = 'FirstName';
    final String lastName = 'LastName';
    final String username = 'username';
    final String bio = 'This is a sample bio';
    final int friendsCount = 315;
    final int eventsAttendedCount = 132;
    final int totalTime = 500; // Time in hours...?
    // something about clubs here...?
    // TODO: replace with logic to get user's clubs -> need more details like club link, club colour, etc...
    final List<String> clubs = ['UWHH', 'Origins', 'HaebeatDanceCrew']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Profile Page'),
        // centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.menu), onPressed: () {})],
      ),
      body: Column(
        children: [
          ProfileTopPage(),
        ],
      ),
    );
  }
}
