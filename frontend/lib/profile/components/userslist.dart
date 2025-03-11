import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../profilemain.dart'; // Import your profile page

class UserListPage extends StatefulWidget {
  final int userId;
  final String listType; // "followers" or "followings"

  const UserListPage({super.key, required this.userId, required this.listType});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUsers(); // Ensure fresh data when the page appears
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUsers(); // Fetch fresh data when page becomes active
  }

  /// **Fetch followers or following list from API**
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final response = await http.get(Uri.parse('$apiUrl/${widget.listType}/${widget.userId}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> userList = decodedData[widget.listType] ?? []; // Extracts "followers" or "following"

        // Print userData for debugging
        print('Fetched ${widget.listType}: $decodedData');
        print('Fetched ${widget.listType}: $userList');

        setState(() {
          _users = userList.cast<Map<String, dynamic>>(); // Ensure correct format
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listType == "followers" ? "Followers" : "Followings"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text("Failed to load users", style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return _buildUserCard(user);
                  },
                ),
    );
  }

  /// **User card widget**
  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileMainPage(profileUserId: user['id']),
              ),
            );
          },
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(user['profile_picture'] ??
                'https://newprofilepic.photo-cdn.net//assets/images/article/profile.jpg?90af0c8'),
          ),
        ),
        title: Text(user['username'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user['bio'] ?? "No bio available"),
      ),
    );
  }
}

