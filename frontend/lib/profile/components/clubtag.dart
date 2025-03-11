import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart'; // https://pub.dev/packages/persistent_bottom_nav_bar
import 'package:frontend/posts/all_posts_page.dart';

class ClubTag extends StatelessWidget {
  final String clubTag;
  final String clubPageRoute; // Link to corresponding club page
  final Color? clubColor; // Optional club color parameter

  // Define a default internal color
  static const Color _defaultColor = Colors.blueAccent;

  const ClubTag({super.key, required this.clubTag, required this.clubPageRoute, this.clubColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the club page when tapped
        // TODO: SHOULD GO TO CLUB PAGE FIX THIS??
        PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(name: clubPageRoute),
          screen: PostsPage(),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: clubColor ?? _defaultColor),
          boxShadow: [
            BoxShadow(
              color: clubColor ?? _defaultColor, // Colored shadow with opacity
              spreadRadius: 0,
              blurRadius: 0,
              offset: Offset(3, 3), // Shadow position
            ),
          ],
        ),
        child: Text(
          '#$clubTag',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}