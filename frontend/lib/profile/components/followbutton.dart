import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FollowButton extends StatefulWidget {
  final int currentUserId; // Current profile's username
  final int profileUserId; // Profile being viewed

  const FollowButton({super.key, required this.currentUserId, required this.profileUserId});

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
    setState(() => isLoading = true);

    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final response = await http.get(Uri.parse('$apiUrl/followings/${widget.currentUserId}'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> followings = data['followings'] ?? [];

        bool follows = followings.any((user) => user['id'] == widget.profileUserId);

        setState(() {
          isFollowing = follows;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch follow status");
      }
    } catch (e) {
      print("Error fetching follow status: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => isFollowing = !isFollowing); // Optimistic update

    final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
    final url = isFollowing ? '$apiUrl/follow' : '$apiUrl/unfollow';
    final reqBody = jsonEncode({
                      "follower_id": widget.currentUserId,
                      "following_id": widget.profileUserId
                    });

    try {
      final response = await (isFollowing
          ? http.post( // Use POST for follow
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: reqBody
            )
          : http.delete( // Use DELETE for unfollow
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: reqBody
            )
        );
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
