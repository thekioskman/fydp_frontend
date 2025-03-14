import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../clubs/club.dart';
import '../clubs/clubdetail.dart';
import '../profile/components/profilesection.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> clubs = [];
  List<dynamic> users = [];
  bool isLoading = false;
  bool hasError = false;

  Future<void> search(String query) async {
    setState(() {
      isLoading = true;
      hasError = false;
      clubs = [];
      users = [];
    });

    final String apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

    try {
      final clubResponse = await http.get(Uri.parse('$apiUrl/search/clubs?query=$query'));
      final userResponse = await http.get(Uri.parse('$apiUrl/search/users?query=$query'));

      if (clubResponse.statusCode == 200 && userResponse.statusCode == 200) {
        final clubData = jsonDecode(clubResponse.body);
        final userData = jsonDecode(userResponse.body);

        setState(() {
          clubs = clubData['data']; // Extract clubs list
          users = userData['data']; // Extract users list
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch results.");
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
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
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for clubs or users...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      search(searchController.text);
                    }
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),

            // Loading Indicator
            if (isLoading) CircularProgressIndicator(),

            // Error Message
            if (hasError) Text("Failed to load results", style: TextStyle(color: Colors.red)),

            // Display Search Results
            if (!isLoading && !hasError)
              Expanded(
                child: ListView(
                  children: [
                    if (clubs.isNotEmpty) ...[
                      Text("Clubs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...clubs.map((club) => ListTile(
                        leading: Icon(Icons.group, color: Colors.blue),
                        title: Text(club['name']),
                        subtitle: Text(club['description'] ?? "No description available"),
                        onTap: () {
                          // Convert API response into a Club model and navigate to ClubDetailPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClubDetailPage(
                                club: Club.fromJson(club), // Convert JSON to Club model
                              ),
                            ),
                          );
                        },
                      )).toList(),
                    ],

                    if (users.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text("Users", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...users.map((user) => ListTile(
                        leading: Icon(Icons.person, color: Colors.green),
                        title: Text(user['username']),
                        subtitle: Text("${user['first_name']} ${user['last_name']}"),
                        onTap: () {
                          // Navigate to ProfileSectionPage from profilesection.dart
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileSectionPage(
                                sectionName: "Profile",
                                userId: user['id'],
                              ),
                            ),
                          );
                        },
                      )).toList(),
                    ],

                    if (clubs.isEmpty && users.isEmpty && !isLoading)
                      Center(child: Text("No results found")),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
