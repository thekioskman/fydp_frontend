import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../clubs/club.dart';
import '../clubs/clubdetail.dart';
import '../profile/components/profilesection.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:frontend/profile/profilemain.dart';
import 'package:frontend/clubs/club_home_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController clubSearchController = TextEditingController();
  TextEditingController userSearchController = TextEditingController();

  List<dynamic> clubs = [];
  List<dynamic> users = [];

  bool isLoadingClubs = false;
  bool hasErrorClubs = false;
  bool isLoadingUsers = false;
  bool hasErrorUsers = false;

  Future<void> searchClubs(String query) async {
    setState(() {
      isLoadingClubs = true;
      hasErrorClubs = false;
      clubs = [];
    });

    final String apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

    try {
      final response = await http.get(Uri.parse('$apiUrl/search/clubs?query=$query'));

      if (response.statusCode == 200) {
        final clubData = jsonDecode(response.body);
        setState(() {
          clubs = clubData['data'];
          isLoadingClubs = false;
        });
      } else {
        throw Exception("Failed to fetch club results.");
      }
    } catch (error) {
      setState(() {
        hasErrorClubs = true;
        isLoadingClubs = false;
      });
    }
  }

  Future<void> searchUsers(String query) async {
    setState(() {
      isLoadingUsers = true;
      hasErrorUsers = false;
      users = [];
    });

    final String apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

    try {
      final response = await http.get(Uri.parse('$apiUrl/search/users?query=$query'));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          users = userData['data'];
          isLoadingUsers = false;
        });
      } else {
        throw Exception("Failed to fetch user results.");
      }
    } catch (error) {
      setState(() {
        hasErrorUsers = true;
        isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Club Search Bar
            TextField(
              controller: clubSearchController,
              decoration: InputDecoration(
                hintText: "Search for clubs...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (clubSearchController.text.isNotEmpty) {
                      searchClubs(clubSearchController.text);
                    }
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),

            // Loading Indicator for Clubs
            if (isLoadingClubs) CircularProgressIndicator(),

            // Error Message for Clubs
            if (hasErrorClubs) Text("Failed to load clubs", style: TextStyle(color: Colors.red)),

            // Display Club Search Results
            if (!isLoadingClubs && !hasErrorClubs)
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (clubs.isNotEmpty) ...[
                      Text("Clubs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...clubs.map((club) => ListTile(
                        leading: Icon(Icons.group, color: Colors.blue),
                        title: Text(club['name']),
                        subtitle: Text(club['description'] ?? "No description available"),
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context, 
                            screen: ClubHomePage(club: Club.fromJson(club)), 
                          );
                        },
                      )).toList(),
                    ],
                    if (clubs.isEmpty && !isLoadingClubs) Center(child: Text("No clubs found")),
                  ],
                ),
              ),

            SizedBox(height: 20),

            // User Search Bar
            TextField(
              controller: userSearchController,
              decoration: InputDecoration(
                hintText: "Search for users...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (userSearchController.text.isNotEmpty) {
                      searchUsers(userSearchController.text);
                    }
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),

            // Loading Indicator for Users
            if (isLoadingUsers) CircularProgressIndicator(),

            // Error Message for Users
            if (hasErrorUsers) Text("Failed to load users", style: TextStyle(color: Colors.red)),

            // Display User Search Results
            if (!isLoadingUsers && !hasErrorUsers)
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (users.isNotEmpty) ...[
                      Text("Users", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...users.map((user) => ListTile(
                        leading: Icon(Icons.person, color: Colors.green),
                        title: Text(user['username']),
                        subtitle: Text("${user['first_name']} ${user['last_name']}"),
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context, 
                            screen: ProfileMainPage(profileUserId: user['id']), 
                          );
                        },
                      )).toList(),
                    ],
                    if (users.isEmpty && !isLoadingUsers) Center(child: Text("No users found")),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
