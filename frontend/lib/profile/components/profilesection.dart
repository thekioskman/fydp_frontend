// This class is for any generic profile section (e.g. Session, Covers, etc. of the figma)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/profilevideosmain.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class ProfileSectionPage extends StatefulWidget {
  final String sectionName; 

  const ProfileSectionPage({super.key, required this.sectionName});

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

  // TODO: actually call backend here
  Future<void> fetchVideos() async {
    try {
      // final response = await http.get(Uri.parse('https://api.example.com/videos'));
      // YoutubePlayer.convertUrlToId => can use to convert urls to ids!
      await Future.delayed(Duration(seconds: 1)); // Simulate API delay
      final List<String> dummyData = [
        'yVfvsYtxkIA',
        'tdVfXhzMbQY',
        'TK8ldqYyfAQ',
      ];

      setState(() {
        videoIDs = dummyData;
        _controllers = videoIDs.map((id) => YoutubePlayerController(
              initialVideoId: id,
              flags: YoutubePlayerFlags(autoPlay: false, mute: false),
            )).toList();
        isLoading = false;
      });

      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
        
      //   setState(() {
      //     videoIDs = data.map((video) => video['youtube_id'] as String).toList();
      //     _controllers = videoIDs.map((id) => YoutubePlayerController(
      //           initialVideoId: id,
      //           flags: YoutubePlayerFlags(autoPlay: false, mute: false),
      //         )).toList();
      //     isLoading = false;
      //   });
      // } else {
      //   setState(() {
      //     hasError = true;
      //     isLoading = false;
      //   });
      // }
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
                Navigator.push(
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

        // Carousel of Video Cards Here
        if (!isLoading && !hasError && videoIDs.isNotEmpty) 
          CarouselSlider(
            options: CarouselOptions(
              height: 250,
              enlargeCenterPage: true, 
              autoPlay: false,
              scrollPhysics: BouncingScrollPhysics(),
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
