import 'package:flutter/material.dart';
import '../components/youtubeVideoListItem.dart';

class ProfileVideosMainPage extends StatefulWidget {
  final String sectionName; 
  final List<String> videoIDs;

  const ProfileVideosMainPage({super.key, required this.sectionName, required this.videoIDs});

  @override
  _ProfileVideosMainPageState createState() => _ProfileVideosMainPageState();
}

class _ProfileVideosMainPageState extends State<ProfileVideosMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sectionName)),
      body: widget.videoIDs.isEmpty
        ? const Center(child: Text("No Videos Available"))
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List of Videos
            Expanded(
              child: ListView.builder(
                itemCount: widget.videoIDs.length,
                itemBuilder: (context, index) {
                  return YoutubeVideoListItem(videoId: widget.videoIDs[index]);
                },
              ),
            ),
          ],
        )
    );
  }
}