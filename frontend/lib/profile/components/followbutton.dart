import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  final String currentUsername; // Current profile's username
  final String profileUsername; // Profile being viewed

  const FollowButton({super.key, required this.currentUsername, required this.profileUsername});

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowing = false; // Toggle state
  bool isLoading = true; // Show loading state initially

  @override
  void initState() {
    super.initState();
    _fetchFollowStatus(); // Fetch from backend when widget loads
  }

  Future<void> _fetchFollowStatus() async {
    try {
      // API call to check if current user is following the profile
      await Future.delayed(Duration(seconds: 1)); // Simulate API delay
      bool fetchedStatus = await checkIfFollowing(
        widget.currentUsername,
        widget.profileUsername,
      );

      setState(() {
        isFollowing = fetchedStatus;
        isLoading = false; // Hide loader after fetching
      });
    } catch (e) {
      print("Error fetching follow status: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => isFollowing = !isFollowing); // Optimistic update

    try {
      // API call to toggle follow status
      await Future.delayed(Duration(milliseconds: 500));

      bool success = await updateFollowStatus(
        widget.currentUsername,
        widget.profileUsername,
        isFollowing,
      );
      if (!success) {
        setState(() => isFollowing = !isFollowing); // Revert if API fails
      }
    } catch (e) {
      print("Error updating follow status: $e");
      setState(() => isFollowing = !isFollowing); // Revert if error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 120, // Match button size 
        height: 40, 
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return ElevatedButton(
      onPressed: _toggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.lightBlue.shade100 : Colors.grey.shade300,
        side: BorderSide(
          color: isFollowing ? Colors.blue.shade700 : Colors.grey.shade700,
          width: isFollowing ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isFollowing ? "Following" : "Follow",
        style: TextStyle(
          color: isFollowing ? Colors.blue.shade900 : Colors.black,
        ),
      ),
    );
  }
}

// 🔹 Dummy API Functions (Replace with actual backend calls)
Future<bool> checkIfFollowing(String currentUsername, String profileUsername) async {
  // Simulate backend check (replace with actual API call)
  return Future.value(false); // Example condition, for now, always start with user NOT following this user
}

Future<bool> updateFollowStatus(String currentUsername, String profileUsername, bool isFollowing) async {
  // Simulate backend update (replace with actual API call)
  print("${isFollowing ? "Following" : "Unfollowing"} $profileUsername by $currentUsername");
  return Future.value(true); // Simulate success
}

