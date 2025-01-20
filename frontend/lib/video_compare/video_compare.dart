import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoComparePage extends StatefulWidget {
  const VideoComparePage({super.key});

  @override
  _VideoComparePageState createState() => _VideoComparePageState();
}

class _VideoComparePageState extends State<VideoComparePage> {
  PlatformFile? video1File;
  PlatformFile? video2File;
  VideoPlayerController? video1Controller;
  VideoPlayerController? video2Controller;
  String message = "";
  List<Map<String, dynamic>> mismatches = [];
  bool isLoading = false; // Indicates if the comparison is in progress

  Future<void> pickVideo(int videoNumber) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() {
        if (videoNumber == 1) {
          video1File = result.files.single;
          if (!kIsWeb) {
            video1Controller = VideoPlayerController.file(File(video1File!.path!))
              ..initialize().then((_) => setState(() {}));
          } else {
            video1Controller = VideoPlayerController.networkUrl(
                Uri.dataFromBytes(video1File!.bytes!, mimeType: 'video/mp4'))
              ..initialize().then((_) => setState(() {}));
          }
        } else {
          video2File = result.files.single;
          if (!kIsWeb) {
            video2Controller = VideoPlayerController.file(File(video2File!.path!))
              ..initialize().then((_) => setState(() {}));
          } else {
            video2Controller = VideoPlayerController.networkUrl(
                Uri.dataFromBytes(video2File!.bytes!, mimeType: 'video/mp4'))
              ..initialize().then((_) => setState(() {}));
          }
        }
      });
    }
  }

  Future<void> compareVideos() async {
    if (video1File == null || video2File == null) {
      setState(() {
        message = "Please select both videos.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = "Awaiting comparison...";
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/compare'),
    );

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'video1',
          video1File!.bytes!,
          filename: video1File!.name,
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'video2',
          video2File!.bytes!,
          filename: video2File!.name,
        ),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath('video1', video1File!.path!));
      request.files.add(await http.MultipartFile.fromPath('video2', video2File!.path!));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var data = json.decode(responseData);

      setState(() {
        isLoading = false;
        message = data['is_matching']
            ? "The videos are matching!"
            : "Overall Evaluation: ${data['overall_evaluation']}";
        mismatches = List<Map<String, dynamic>>.from(data['mismatches']);
      });
    } else {
      setState(() {
        isLoading = false;
        message = "Error: Unable to compare videos.";
      });
    }
  }

  @override
  void dispose() {
    video1Controller?.dispose();
    video2Controller?.dispose();
    super.dispose();
  }

  Widget buildVideoPlayer(
      VideoPlayerController? controller, String buttonLabel, VoidCallback onUpload, VoidCallback onPlayPause) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onUpload,
          child: Text(buttonLabel),
        ),
        if (controller != null && controller.value.isInitialized)
          Column(
            children: [
              SizedBox(
                height: 200,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: onPlayPause,
                  ),
                  SizedBox(
                    width: 150,
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Comparison')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildVideoPlayer(
                        video1Controller,
                        "Upload Video 1",
                        () => pickVideo(1),
                        () {
                          setState(() {
                            if (video1Controller!.value.isPlaying) {
                              video1Controller!.pause();
                            } else {
                              video1Controller!.play();
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: buildVideoPlayer(
                        video2Controller,
                        "Upload Video 2",
                        () => pickVideo(2),
                        () {
                          setState(() {
                            if (video2Controller!.value.isPlaying) {
                              video2Controller!.pause();
                            } else {
                              video2Controller!.play();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator(), // Show loading symbol when comparing
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: compareVideos,
              child: Text('Compare Videos'),
            ),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: mismatches.length,
                itemBuilder: (context, index) {
                  var mismatch = mismatches[index];
                  return ListTile(
                    title: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (video1Controller != null && video2Controller != null) {
                            video1Controller!.seekTo(Duration(seconds: mismatch['timestamp'].toInt()));
                            video2Controller!.seekTo(Duration(seconds: mismatch['timestamp'].toInt()));
                          }
                        },
                        child: Text(
                          "Timestamp: ${mismatch['timestamp']}s",
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    subtitle: Text(
                        "Evaluation: ${mismatch['evaluation']}, Mean Difference: ${mismatch['mean_difference']}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
