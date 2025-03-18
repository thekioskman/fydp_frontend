import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/profile/profilemain.dart'; // Import your profile page

class MemberListPage extends StatefulWidget {
  final int clubId;

  const MemberListPage({super.key, required this.clubId,});

  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
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
      final response = await http.get(Uri.parse('$apiUrl/club/${widget.clubId}/members'));
      print("YEET");
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> userList = decodedData['members'] ?? []; // Extracts "followers" or "following"

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
        title: Text("Club Members"),
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
                'https://www.shutterstock.com/image-vector/dancing-icon-logo-design-vector-600nw-2229555929.jpg'),
          ),
        ),
        title: Text(user['username'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user['bio'] ?? "No bio available"),
      ),
    );
  }
}

