import 'package:flutter/material.dart';
import '../../login/login.dart'; // TODO: remove later


class ClubTag extends StatelessWidget {
  final String clubName;
  final String clubPageRoute; // Link to corresponding club page
  final Color? clubColor; // Optional club color parameter

  // Define a default internal color
  static const Color _defaultColor = Colors.blueAccent;

  ClubTag({required this.clubName, required this.clubPageRoute, this.clubColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the club page when tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(title: "Login from club")) // TODO: fix this later with the club page, get club page by club name! -> might introduce club ID in future
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
          '#$clubName',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}