// This class is for any generic profile section (e.g. Session, Covers, etc. of the figma)
import 'package:flutter/material.dart';
import '../pages/profilevideosmain.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For decoding JSON


class ProfileSectionPage extends StatefulWidget {
  final String sectionName; 
  final int userId;

  const ProfileSectionPage({super.key, required this.sectionName, required this.userId});

  @override
  _ProfileSectionPageState createState() => _ProfileSectionPageState();
}

class _ProfileSectionPageState extends State<ProfileSectionPage> {
  List<String> videoIDs = [];
  bool isLoading = true; // to track loading state
  bool hasError = false; // to track errors
  late List<YoutubePlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final Map<String, dynamic> requestBody = {
        "user_id": widget.userId, // Replace with dynamic user ID if needed
        "timestamp": "1970-01-01T00:00:00Z" // Fetch all videos of all time
      };
      final response = await http.post(
        Uri.parse('$apiUrl/user/events'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (!data.containsKey("events") || data["events"] == null) {
          throw Exception("No 'events' key in response.");
        }

        final List<dynamic> events = data["events"];

        // Filter events that have a non-null "video_url"
        final List<String> validVideoIds = events
            .where((event) => event["video_url"] != null) // Only keep valid URLs
            .map<String>((event) => YoutubePlayer.convertUrlToId(event["video_url"].toString()) ?? "")
            .where((id) => id.isNotEmpty) // Remove failed conversions
            .toList()
            .reversed // Reverse to get the newest videos first
            .take(3) // Keep at most 3 videos
            .toList();

        setState(() {
          videoIDs = validVideoIds;
          _controllers = videoIDs.map((id) => YoutubePlayerController(
            initialVideoId: id,
            flags: YoutubePlayerFlags(autoPlay: false, mute: false),
          )).toList();
          isLoading = false;
        });

        print("Fetched Video IDs: $videoIDs");
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
      // YoutubePlayer.convertUrlToId => can use to convert urls to ids!
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 16.0, left: 16.0),
                child: Text(
                  widget.sectionName,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                )),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileVideosMainPage()),
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
        if (isLoading) 
          CircularProgressIndicator(),
        
        // Error message
        if (hasError) 
          Text("Failed to load videos", style: TextStyle(color: Colors.red)),

        // If no videos available, show "No videos for events yet!"
        if (!isLoading && !hasError && videoIDs.isEmpty)
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
        if (!isLoading && !hasError && videoIDs.isNotEmpty) 
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
    );
  }
}
