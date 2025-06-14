import 'package:flutter/material.dart';
import 'components/profiletop.dart';
import 'components/upcomingevents.dart';
import 'components/activities.dart';
import 'components/profilesection.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For caching data
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For decoding JSON
import '../clubs/club.dart';

class ProfileMainPage extends StatefulWidget {
  int profileUserId; // Allows viewing another user's profile
  final bool isOwnProfile; // Only used for main:sketchy solution to set profile page properly during initial login

  ProfileMainPage({super.key, required this.profileUserId, this.isOwnProfile = false,});

  @override
  _ProfileMainPageState createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
  // Keys to access sub widgets of the main page
  final GlobalKey<ProfileSectionPageState> _profileSectionKey = GlobalKey();
  final GlobalKey<UpcomingEventsPageState> _upcomingEventsPageKey = GlobalKey();

  String? _latestTimestamp;
  int _user_id = -1;
  bool _isLoading = true;
  bool _hasError = false;

  String profilePicUrl = '';
  String firstName = '';
  String lastName = '';
  String username = '';
  String bio = '';
  int followersCount = 0;
  int followingCount = 0;
  int eventsAttendedCount = 0;
  double totalTime = 0; // Time in hours...?
  List<Club> clubs = []; 

  @override
  void initState() {
    super.initState();
    _loadCachedUserData(); // Ensure fresh data when the page appears
  }

  Future<void> _refreshProfile() async {
    await _loadCachedUserData();
    await _fetchUserData(); // Fetch user data

    // Call fetchVideos() in ProfileSectionPage
    _profileSectionKey.currentState?.fetchVideos();

    // Call fetchUpcomingEvent() in UpcomingEventsPage
    _upcomingEventsPageKey.currentState?.fetchUpcomingEvent();
  }

  /// **Load cached timestamp & user ID from SharedPreferences**
  Future<void> _loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _latestTimestamp = prefs.getString('latest_timestamp') ??
          DateTime.now().toUtc().subtract(Duration(days: 2)).toIso8601String();
      _user_id = int.tryParse(prefs.getString("user_id") ?? "") ?? -1;
    });

    // Check if isOwnProfile is true; if true, set profileUserId to _user_id
    if (widget.isOwnProfile) {
      setState(() {
        widget.profileUserId = _user_id;
      });
    }

    _fetchUserData();
  }

  /// **Fetch user data from API**
  Future<void> _fetchUserData() async {
    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      
      // Fetch user info
      final userResponse = await http.get(Uri.parse('$apiUrl/user/${widget.profileUserId}'));
      if (userResponse.statusCode != 200) throw Exception('Failed to load user data');
      final userData = jsonDecode(userResponse.body)['user'];

      // Print userData for debugging
      print('Fetched User Data: $userData');

      // Fetch user's clubs
      final clubsResponse = await http.get(Uri.parse('$apiUrl/user/${widget.profileUserId}/clubs'));
      if (clubsResponse.statusCode != 200) throw Exception('Failed to load clubs');

      final List<dynamic> clubData = jsonDecode(clubsResponse.body)['clubs'];
      
      setState(() {

        profilePicUrl = userData['profile_picture'] ?? 'https://www.shutterstock.com/image-vector/dancing-icon-logo-design-vector-600nw-2229555929.jpg';
        firstName = userData['first_name'] ?? 'Unknown';
        lastName = userData['last_name'] ?? '';
        username = userData['username'] ?? 'unknown_user';
        bio = userData['bio'] ?? 'This is a sample bio';
        followersCount = userData['followers'] ?? 0;
        followingCount = userData['following'] ?? 0;
        eventsAttendedCount = userData['sessions_attended'] ?? 0;
        // Convert totalTime from minutes to hours with one decimal place
        totalTime = ((userData['total_dance_time'] ?? 0) / 60).toDouble();
        totalTime = double.parse(totalTime.toStringAsFixed(1));
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
            : RefreshIndicator(
              onRefresh: _refreshProfile,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ProfileTopPage(
                    currentUserId: _user_id,
                    profileUserId: widget.profileUserId,
                    profilePicUrl: profilePicUrl,
                    firstName: firstName,
                    lastName: lastName,
                    username: username,
                    bio: bio,
                    followersCount: followersCount,
                    followingCount: followingCount,
                    eventsAttendedCount: eventsAttendedCount,
                    totalTime: totalTime,
                    clubs: clubs,
                    isOwnProfile: _user_id == widget.profileUserId,
                  ),
                  UpcomingEventsPage(key: _upcomingEventsPageKey, userId: widget.profileUserId,),
                  ActivitiesPage(),
                  ProfileSectionPage(key: _profileSectionKey, sectionName: "Videos", userId: widget.profileUserId),
                  // ProfileSectionPage(sectionName: "Covers"),
                  SizedBox(height: 24.0)
                ],
              )
            ),
    );
  }
}
