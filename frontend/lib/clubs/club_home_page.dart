import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'club.dart';
import 'package:frontend/profile/components/clubtag.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:frontend/clubs/memberslist.dart';
import 'package:frontend/profile/pages/profilevideosmain.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/clubs/create_event.dart';
import 'package:frontend/clubs/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For decoding JSON
import 'package:shared_preferences/shared_preferences.dart'; // For caching data
import 'view_event.dart';


class ClubHomePage extends StatefulWidget {
  final Club club;

  const ClubHomePage({super.key, required this.club});

  @override
  _ClubHomePageState createState() => _ClubHomePageState();
}

class _ClubHomePageState extends State<ClubHomePage> {
  bool _isLoading = true;
  bool _hasError = false;
  bool isOwner = false;

  // More club details
  String? _latestTimestamp;
  int _userId = -1; // Logged in user
  int membersCount = 0;
  int eventsCount = 0;

  // Event Videos Section
  bool _isVideosLoading = true;
  bool _videosHaveError = false;
  List<String> topVideoIDs = [];
  List<String> allVideoIDs = [];
  late List<YoutubePlayerController> _controllers;

  // Events Section
  Event? mostRecentEvent;
  List<Event> allEvents = [];

  // Only used if isOwner is false
  bool isMember = false;

  @override
  void initState() {
    super.initState();
    _refreshClub(); // Ensure fresh data when the page appears
  }

  Future<void> _refreshClub() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _latestTimestamp = prefs.getString('latest_timestamp') ??
          DateTime.now().toUtc().subtract(Duration(days: 2)).toIso8601String();
      _userId = int.tryParse(prefs.getString("user_id") ?? "") ?? -1;
    });

    _fetchClubMembers();

    _fetchClubDetails();

    setState(() {
      _isLoading = false;
    });

    _fetchEventsAndVideos();
  }

  Future<void> _fetchFollowStatus() async {
    try {
      // Check if user is already member of the club or not
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final response = await http.get(Uri.parse('$apiUrl/user/$_userId/clubs'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey("clubs")) {
          final List<dynamic> clubs = data["clubs"];

          // Check if the user follows the current club
          for (var club in clubs) {
            if (club["id"] == widget.club.id) {
              setState(() => isMember = true);
              break;
            }
          }
        }
        
      } else {
        throw Exception("Failed to club details (status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClubDetails() async {
    try {
      // Check if owner --> if not, check if member
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final response = await http.get(Uri.parse('$apiUrl/club/${widget.club.id}'));

      if (response.statusCode == 200) {
        final int ownerId = jsonDecode(response.body)['owner'] ?? -1;

        if (ownerId == _userId) {
          setState(() {
            isOwner = true;
          });
        } else {
          _fetchFollowStatus();
        }
        
      } else {
        throw Exception("Failed to club details (status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClubMembers() async {
    try {
      // update number of followers
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final response = await http.get(Uri.parse('$apiUrl/club/${widget.club.id}/members'));

      if (response.statusCode == 200) {
        final List<dynamic> memberList = jsonDecode(response.body)['members'] ?? [];

        setState(() {
          membersCount = memberList.length;
        });
      } else {
        throw Exception("Failed to club details (status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchEventsAndVideos() async {
    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final Map<String, dynamic> requestBody = {
        "club_id": widget.club.id, // Replace with dynamic user ID if needed
        "timestamp": "1970-01-01T00:00:00Z" // Fetch all videos of all time
      };
      final response = await http.post(
        Uri.parse('$apiUrl/club/events'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (!data.containsKey("events") || data["events"] == null) {
          throw Exception("No 'events' key in response.");
        }

        final List<dynamic> events = data["events"];
        // The following is to get upcoming events
        final List<Event> parsedEvents = events
          .map((event) => Event.fromJson(event))
          .toList()
          ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date))); // Sort future first

        print(parsedEvents);
        // The following is to get Videos for events
        // Filter events that have a non-null "video_url"
        final List<String> validVideoIds = events
            .where((event) => event["video_url"] != null) // Only keep valid URLs
            .map<String>((event) => YoutubePlayer.convertUrlToId(event["video_url"].toString()) ?? "")
            .where((id) => id.isNotEmpty) // Remove failed conversions
            .toList()
            .reversed // Reverse to get the newest videos first
            .toList();

        setState(() {
          allEvents = parsedEvents;
          eventsCount = events.length;
          allVideoIDs = validVideoIds;
          topVideoIDs = validVideoIds.take(3).toList();
          _controllers = topVideoIDs.map((id) => YoutubePlayerController(
            initialVideoId: id,
            flags: YoutubePlayerFlags(autoPlay: false, mute: false),
          )).toList();
          _isVideosLoading = false;
        });

      } else {
        print(response.statusCode);
        throw Exception("Failed to load events (status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _videosHaveError = true;
        _isVideosLoading = false;
      });
    }
  }

  Future<void> _toggleJoin() async {
    setState(() => isMember = !isMember);

    final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
    final reqBody = jsonEncode({
                      "user_id": _userId,
                    });

    try{
      final response = await (isMember
        ? http.post( // Use POST for adding members
            Uri.parse('$apiUrl/club/${widget.club.id}/members'),
            headers: {'Content-Type': 'application/json'},
            body: reqBody
          )
        : http.delete( // Use DELETE for removing members
            Uri.parse('$apiUrl/club/${widget.club.id}/members/$_userId'),
            headers: {'Content-Type': 'application/json'},
          )
      );
    } catch (e) {
      print("Error updating member status: $e");
      setState(() => isMember = !isMember); // Revert if error
    }
  }

  /// **Format event time into 12-hour AM/PM format**
  String formatEventTime(String time) {
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time"); // Add a dummy date
      return DateFormat.jm().format(parsedTime); // Format as "7 AM", "8 PM", etc.
    } catch (e) {
      print("Error formatting time: $time");
      return time; // Fallback to original time
    }
  }

  // void _createEvent(BuildContext context) async {
  //   PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
  //     context,
  //     settings: RouteSettings(name: "CreateEventScreen"),
  //     screen: CreateEventPage(club_id : widget.club.id),
  //     withNavBar: true,
  //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.name),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _hasError 
          ? Center(child: Text("Failed to load profile", style: TextStyle(color: Colors.red)))
          : RefreshIndicator(
            onRefresh: _refreshClub,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Picture banner...? -> make it some stock photo for now... -------------------
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider('https://cdn.pixabay.com/photo/2016/02/03/08/33/banner-1176678_640.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Top contents (name, username, follow button...?) ------------------
                Column (
                  children: [
                    Row (
                      children: [
                        // Title + Club Tag
                        Row (
                          children: [
                            Padding (
                              padding: EdgeInsets.only(top: 10.0, bottom: 16.0, left: 16.0),
                              child: Text(
                                widget.club.name,
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                              )
                            ),
                            SizedBox(width: 10),
                            ClubTag(club: widget.club, clubColor: widget.club.color, link: false)
                          ],
                        ),                        
                      ]
                    ),

                    // Join button (if not owner)
                    if (!isOwner)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: _toggleJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMember ? Colors.lightBlue.shade100 : Colors.grey.shade300,
                              side: BorderSide(
                                color: isMember ? Colors.blue.shade700 : Colors.grey.shade700,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 20,
                              child: Center(
                                child: Text(
                                  isMember ? "Joined" : "Join",
                                  style: TextStyle(
                                    color: isMember ? Colors.blue.shade900 : Colors.black,
                                  )
                                )
                              )
                            )
                          ),
                        )
                      ),
                    // Bio
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 16.0, left: 16.0, right: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.club.description,
                          textAlign: TextAlign.left, // Ensure text inside is also left-aligned
                        ),
                      ),
                    ),

                    // Stats
                    Divider(),
                    Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 16.0, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                                context, 
                                screen: MemberListPage(clubId: widget.club.id), 
                                settings: RouteSettings(name: "FollowersListPage"), // Define a route name
                              );
                            },
                            child: _buildStatColumn('Members', membersCount),
                          ),
                          _buildStatColumn('Events Held', eventsCount),
                          // Location is permanently Waterloo for now
                          Column(
                            children: [
                              Center(
                                child: Text('Location', style: TextStyle(fontSize: 14)),
                              ),
                              Center(
                                child: Text(
                                  "Waterloo",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ),
                    Divider(),
                  ],
                ),

                // Event Videos -----------------------------------
                Column(
                  children: [
                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 20.0, bottom: 16.0, left: 16.0),
                            child: Text(
                              "Event Videos",
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                            )),
                        GestureDetector(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                              context,
                              screen: ProfileVideosMainPage(
                                  sectionName: "Videos",
                                  videoIDs: allVideoIDs,
                                ),
                              settings: RouteSettings(name: "ProfileVideosMainPage"), // Define a route name
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              ">",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Loading indicator
                    if (_isVideosLoading) 
                      CircularProgressIndicator(),
                    
                    // Error message
                    if (_videosHaveError) 
                      Text("Failed to load videos", style: TextStyle(color: Colors.red)),

                    // If no videos available, show "No videos for events yet!"
                    if (!_isVideosLoading && !_videosHaveError && topVideoIDs.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            "No videos for events yet!",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ),

                    // Carousel of Video Cards Here
                    if (!_isVideosLoading && !_videosHaveError && topVideoIDs.isNotEmpty) 
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 250,
                          enlargeCenterPage: true, 
                          autoPlay: false,
                          scrollPhysics: _controllers.length == 1 
                            ? NeverScrollableScrollPhysics()  // Disables scrolling if only 1 item
                            : BouncingScrollPhysics(),
                          enableInfiniteScroll: _controllers.length > 1,
                        ),
                        items: _controllers.map((controller) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {}, // Absorb horizontal drag to enable swiping
                              child: YoutubePlayer(
                                  controller: controller, 
                                  showVideoProgressIndicator: true,
                                  // TODO: look into disabling drag to seek
                                ),
                            )
                          );
                        }).toList(),
                      ),
                  ],
                ),

                // Events -----------------------------------------
                Column(
                  children: [
                    // Title Section
                    Row(
                      children: [
                        // Title
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, bottom: 16.0, left: 16.0),
                          child: Text(
                            "Events",
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          )
                        ),
                        Spacer(),
                        // Add Event Button Only in Owner-View
                        if (isOwner)
                          Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue, // Set button color to blue
                              ),
                              child: IconButton(
                                icon: Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context, 
                                    screen: CreateEventPage(club_id : widget.club.id), 
                                  );
                                },
                              ),
                            )
                          ),
                      ],
                    ),

                    // Next Upcoming Event

                  ],
                ),

                // Events List View (Scrollable)
                allEvents.isEmpty
                  ? const Center(child: Text("No Events"))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // List of All Events
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allEvents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Event Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            allEvents[index].eventName,
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Date: ${allEvents[index].date} @ ${formatEventTime(allEvents[index].time)}",
                                            style: TextStyle(fontSize: 16, color: Colors.black),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Location: ${allEvents[index].location}",
                                            style: TextStyle(fontSize: 16, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Arrow Button
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 10),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            PersistentNavBarNavigator.pushNewScreen(
                                              context,
                                              screen: EventDetailPage(eventData :allEvents[index]),
                                              withNavBar: true, // OPTIONAL VALUE. True by default.
                                              pageTransitionAnimation: PageTransitionAnimation.cupertino,);

                                          },
                                          color: Colors.blue,
                                          icon: Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                              )
                            );
                          },
                        )
                      ]
                    )
              ]
            )
          )
    );
  }

  Widget _buildStatColumn(String label, num count) {
    return Column(
      children: [
        Center(
          child: Text(label, style: TextStyle(fontSize: 14)),
        ),
        Center(
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}