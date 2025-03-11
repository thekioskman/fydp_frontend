import 'package:flutter/material.dart';
import 'package:frontend/clubs/create_club.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart'; // https://pub.dev/packages/persistent_bottom_nav_bar
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For caching data
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'club_home_page.dart';
import 'club.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  _ClubsScreenState createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  List<Club> clubs = [];
  bool isLoading = true;
  bool hasError = false;
  String? user_id;

  @override
  void initState() {
    super.initState();
    _init_state();

  }
  Future<void> _init_state() async {
    await _loadUserData();
    await fetchClubs();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString("user_id");
    });
  }

  Future<void> fetchClubs() async {
    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final response = await http.get(
        Uri.parse('$apiUrl/user/$user_id/clubs'), 
      );

      if (response.statusCode == 200) {
        final List<dynamic> allClubs = jsonDecode(response.body)['clubs'] ?? [];

        // Filter out only clubs where the logged-in user is the owner
        final List<Club> ownedClubs = allClubs
          .where((club) => club['owner_id'].toString() == user_id)
          .map((clubData) => Club.fromJson(clubData)) // Convert JSON to Club object
          .toList();

        setState(() {
          clubs = ownedClubs;
          isLoading = false;
          hasError = false;
        });

        print("Owned Clubs: $ownedClubs"); // Debugging
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

void _createClub(BuildContext context) {
  if (!mounted) return;
    PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: CreateClubPage(userId: user_id!),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );

}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("My Clubs"),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: () {
            _createClub(context); // Call your create club function here
          },
          child: Text(
            "Create Club",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchClubs, // Function to call when refreshing
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  final club = clubs[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the club's home page
                      PersistentNavBarNavigator.pushNewScreen(
                        context, 
                        screen: ClubHomePage(club: club), 
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '#${club.clubTag}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
  );
}
}