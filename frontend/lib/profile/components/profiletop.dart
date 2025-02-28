import 'package:flutter/material.dart';
import 'clubtag.dart';
import 'followbutton.dart';
import '../../club/club.dart';

class ProfileTopPage extends StatefulWidget {
  final String profilePicUrl;
  final String firstName;
  final String lastName;
  final String username;
  final String bio;
  final int friendsCount;
  final int eventsAttendedCount;
  final int totalTime;
  final List<Club> clubs;
  final bool isOwnProfile;

  const ProfileTopPage({
    super.key,
    required this.profilePicUrl,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.bio,
    required this.friendsCount,
    required this.eventsAttendedCount,
    required this.totalTime,
    required this.clubs,
    required this.isOwnProfile,
  });

  @override
  _ProfileTopPageState createState() => _ProfileTopPageState();
}

class _ProfileTopPageState extends State<ProfileTopPage> {
  // TODO: replace with logic to get user's clubs -> need more details like club link, club colour, etc...
  // final List<Club> clubs = [
  //   Club(name: 'UWHH', pageRoute: '/login'), 
  //   Club(name: 'Origins', pageRoute: '/login', color: Colors.green), 
  //   Club(name: 'HaebeatDanceCrew', pageRoute: '/login', color: Colors.yellow),
  // ]; 

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
                backgroundImage: NetworkImage(widget.profilePicUrl),
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
                  '${widget.firstName} ${widget.lastName}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '@${widget.username}',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(widget.bio),
              ],
            )
          ),

          // If another profile, show follow button else, no button here
          SizedBox(height: 10),
          widget.isOwnProfile ? const SizedBox.shrink() : SizedBox(
            width: 200,
            height: 30,
            child: FollowButton(currentUsername: widget.username, profileUsername: "profileUsername"),
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
                      child: _buildStatColumn('Friends', widget.friendsCount),
                    )
                  ),
                ),
                _buildStatColumn('Events Attended', widget.eventsAttendedCount),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft, 
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: _buildStatColumn('Total Hours', widget.totalTime),
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
                  children: widget.clubs.map((club) => ClubTag(clubName: club.name, clubPageRoute: club.pageRoute, clubColor: club.color)).toList(),
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