import 'package:flutter/material.dart';
import 'components/profiletop.dart';
import 'components/upcomingevents.dart';
import 'components/activities.dart';
import 'components/profilesection.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For caching data
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For decoding JSON
import '../../club/club.dart';

class ProfileMainPage extends StatefulWidget {
  final int profileUserId; // Allows viewing another user's profile

  const ProfileMainPage({super.key, required this.profileUserId});

  @override
  _ProfileMainPageState createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
  String? _latestTimestamp;
  int _user_id = -1;
  bool _isLoading = true;
  bool _hasError = false;

  String profilePicUrl = '';
  String firstName = '';
  String lastName = '';
  String username = '';
  String bio = '';
  int friendsCount = 0;
  int eventsAttendedCount = 0;
  int totalTime = 0; // Time in hours...?
  List<Club> clubs = []; 

  @override
  void initState() {
    super.initState();
    _loadCachedUserData();
  }

  /// **Load cached timestamp & user ID from SharedPreferences**
  Future<void> _loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _latestTimestamp = prefs.getString('latest_timestamp') ??
          DateTime.now().toUtc().subtract(Duration(days: 2)).toIso8601String();
      _user_id = int.tryParse(prefs.getString("user_id") ?? "") ?? -1;
    });

    _fetchUserData();
  }

  /// **Fetch user data from API**
  Future<void> _fetchUserData() async {
    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      
      // Fetch user info
      final userResponse = await http.get(Uri.parse('$apiUrl/user/$_user_id'));
      if (userResponse.statusCode != 200) throw Exception('Failed to load user data');
      final userData = jsonDecode(userResponse.body)['user'];

      // Fetch user's clubs
      final clubsResponse = await http.get(Uri.parse('$apiUrl/user/$_user_id/clubs'));
      if (clubsResponse.statusCode != 200) throw Exception('Failed to load clubs');

      final List<dynamic> clubData = jsonDecode(clubsResponse.body)['clubs'];
      
      setState(() {

        profilePicUrl = userData['profile_picture'] ?? 'https://newprofilepic.photo-cdn.net//assets/images/article/profile.jpg?90af0c8';
        firstName = userData['first_name'] ?? 'Unknown';
        lastName = userData['last_name'] ?? '';
        username = userData['username'] ?? 'unknown_user';
        bio = userData['bio'] ?? 'This is a sample bio';
        friendsCount = userData['friends_count'] ?? 0;
        eventsAttendedCount = userData['events_attended'] ?? 0;
        totalTime = userData['total_time'] ?? 0;
        clubs = clubData.map((clubJson) => Club.fromJson(clubJson)).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Profile Page'),
        // centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.menu), onPressed: () {})],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
            ? Center(child: Text("Failed to load profile", style: TextStyle(color: Colors.red)))
            : SingleChildScrollView(
              child: Column(
              children: [
                ProfileTopPage(
                  profilePicUrl: profilePicUrl,
                  firstName: firstName,
                  lastName: lastName,
                  username: username,
                  bio: bio,
                  friendsCount: friendsCount,
                  eventsAttendedCount: eventsAttendedCount,
                  totalTime: totalTime,
                  clubs: clubs,
                  isOwnProfile: _user_id == widget.profileUserId,
                ),
                UpcomingEventsPage(),
                ActivitiesPage(),
                // ProfileSectionPage(sectionName: "Sessions"),
                // ProfileSectionPage(sectionName: "Covers"),
                SizedBox(height: 24.0)
              ],
            ),
            ),
    );
  }
}
