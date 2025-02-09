import 'package:flutter/material.dart';
import 'clubtag.dart';
import 'followbutton.dart';
import '../../club/club.dart';

class ProfileTopPage extends StatefulWidget {
  const ProfileTopPage({super.key});

  @override
  _ProfileTopPageState createState() => _ProfileTopPageState();
}

class _ProfileTopPageState extends State<ProfileTopPage> {
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
  final List<Club> clubs = [
    Club(name: 'UWHH', pageRoute: '/login'), 
    Club(name: 'Origins', pageRoute: '/login', color: Colors.green), 
    Club(name: 'HaebeatDanceCrew', pageRoute: '/login', color: Colors.yellow),
  ]; 

  // Personal profile vs. someone else's profile
  final bool isOwnProfile = false;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Top Profile Section -----------------------------------------------------
          // Profile Picture
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(profilePicUrl),
              ),
            ),
          ),
          // Profile Info (Name, Username, Bio)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  firstName + ' ' + lastName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '@$username',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(bio),
              ],
            )
          ),

          // If another profile, show follow button else, no button here
          SizedBox(height: 10),
          isOwnProfile ? const SizedBox.shrink() : SizedBox(
            width: 200,
            height: 30,
            child: FollowButton(currentUsername: username, profileUsername: "profileUsername"),
          ),
          SizedBox(height: 10),
          Divider(),

          // Profile Stats --> look into how far apart we want the stats to be...
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight, 
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: _buildStatColumn('Friends', friendsCount),
                    )
                  ),
                ),
                _buildStatColumn('Events Attended', eventsAttendedCount),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft, 
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: _buildStatColumn('Total Hours', totalTime),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Club Tags -----------------------------------------------------
          Divider(), // remove
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 12, // Vertical space between rows of tags
                  children: clubs.map((club) => ClubTag(clubName: club.name, clubPageRoute: club.pageRoute, clubColor: club.color)).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Center(
          child: Text(label, style: TextStyle(fontSize: 14)),
        ), 
        Center(
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}