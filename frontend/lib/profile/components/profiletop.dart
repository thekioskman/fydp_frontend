import 'package:flutter/material.dart';
import 'package:frontend/profile/components/userslist.dart';
import 'package:frontend/profile/profilemain.dart';
import 'clubtag.dart';
import 'followbutton.dart';
import '../../clubs/club.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileTopPage extends StatelessWidget {
  final int currentUserId; // Logged in user
  final int profileUserId; // Profile page currently being viewed
  final String profilePicUrl;
  final String firstName;
  final String lastName;
  final String username;
  final String bio;
  final int followersCount;
  final int followingCount;
  final int eventsAttendedCount;
  final double totalTime;
  final List<Club> clubs;
  final bool isOwnProfile;

  const ProfileTopPage({
    super.key,
    required this.currentUserId,
    required this.profileUserId,
    required this.profilePicUrl,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.eventsAttendedCount,
    required this.totalTime,
    required this.clubs,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(
                profilePicUrl
              )
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$firstName $lastName',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '@$username',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 8),
              Text(bio),
            ],
          ),
        ),
        SizedBox(height: 10),
        isOwnProfile
            ? const SizedBox.shrink()
            : SizedBox(
                width: 200,
                height: 30,
                child: FollowButton(
                    currentUserId: currentUserId,
                    profileUserId: profileUserId),
              ),
        SizedBox(height: 10),
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                    context, 
                    screen: UserListPage(userId: profileUserId, listType: "followers"), 
                    settings: RouteSettings(name: "FollowersListPage"), // Define a route name
                  );
                },
                child: _buildStatColumn('Followers', followersCount),
              ),
              GestureDetector(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                    context, 
                    screen: UserListPage(userId: profileUserId, listType: "followings"), 
                    settings: RouteSettings(name: "FollowingListPage"), // Define a route name
                  );
                },
                child: _buildStatColumn('Following', followingCount),
              ),
              _buildStatColumn('Events', eventsAttendedCount),
              _buildStatColumn('Total Hours', totalTime),
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 16,
                  runSpacing: 12,
                  children: clubs
                      .map((club) => ClubTag(
                            club: club,
                            clubColor: club.color,
                          ))
                      .toList(),
                ),
              )
              
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStatColumn(String label, num count) {
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
