import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'event.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EventDetailPage extends StatefulWidget {
  final Event eventData;
  final bool isOwner;

  EventDetailPage({required this.eventData, required this.isOwner});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late GoogleMapController mapController;
  late LatLng eventLocation;
  bool isInterested = false;
  bool isLoading = true;
  bool isUpdatingInterest = false;
  bool isUpdatingVideoUrl = false;
  String user_id = "";
  List<int> interestedEventIds = [];
  TextEditingController videoUrlController = TextEditingController();
  late YoutubePlayerController _youtubeController;
  bool _isValidUrl = true;

  @override
  void initState() {
    super.initState();
    eventLocation = LatLng(
      widget.eventData.latitude,
      widget.eventData.longitude,
    );
    videoUrlController.text = widget.eventData.videoUrl ?? '';
    _loadUserData();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    if (_isValidUrl && widget.eventData.videoUrl != null && widget.eventData.videoUrl!.isNotEmpty) {
      _youtubeController.dispose();
    }
    super.dispose();
  }
    void _initializeVideoPlayer() {
    if (widget.eventData.videoUrl != null && widget.eventData.videoUrl!.isNotEmpty) {
      try {
        final videoId = YoutubePlayer.convertUrlToId(widget.eventData.videoUrl!);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
          setState(() => _isValidUrl = true);
        } else {
          setState(() => _isValidUrl = false);
        }
      } catch (e) {
        setState(() => _isValidUrl = false);
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("user_id");
      
      if (userId != null) {
        setState(() {
          user_id = userId;
        });
        await _loadInterestedEvents(userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<List<int>> fetchInterestedEventIds(String userId) async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
    final response = await http.get(
      Uri.parse('$apiUrl/user/$userId/interested'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> events = jsonResponse['events'];
      return events.map<int>((event) => event['id'] as int).toList();
    } else {
      throw Exception('Failed to load interested events');
    }
  }

  Future<void> _loadInterestedEvents(String userId) async {
    try {
      final ids = await fetchInterestedEventIds(userId);
      if (mounted) {
        setState(() {
          isInterested = ids.contains(widget.eventData.id);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading interests: $e')),
      );
    }
  }

  Future<void> _handleInterest() async {
    if (isUpdatingInterest) return;
    
    setState(() => isUpdatingInterest = true);
    
    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final endpoint = '$apiUrl/events/interest';
      final eventId = widget.eventData.id;

      http.Response response;
      
      if (isInterested) {
        response = await http.delete(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'event_id': eventId,
            'user_id': user_id,
          }),
        );
      } else {
        response = await http.post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'event_id': eventId,
            'user_id': user_id,
          }),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          isInterested = !isInterested;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isInterested 
            ? 'Added to your interests!' 
            : 'Removed from interests')),
        );
      } else {
        throw Exception('Server responded with ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdatingInterest = false);
      }
    }
  }

 Future<void> _updateVideoUrl() async {
    if (isUpdatingVideoUrl || videoUrlController.text.isEmpty) return;
    
    setState(() => isUpdatingVideoUrl = true);
    
    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final endpoint = '$apiUrl/events/${widget.eventData.id}';
      
      final response = await http.patch(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'video_url': videoUrlController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video URL updated successfully')),
        );
        // Update the event data with the new video URL
        setState(() {
          widget.eventData.videoUrl = videoUrlController.text;
        });
      } else {
        throw Exception('Server responded with ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating video URL: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdatingVideoUrl = false);
      }
    }
  }

  String formatEventTime(String time) {
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time");
      return DateFormat.jm().format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  Widget _buildVideoSection() {
    if (widget.eventData.videoUrl == null || widget.eventData.videoUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!_isValidUrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Video:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red[50],
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invalid YouTube URL',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'URL: ${widget.eventData.videoUrl}',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Video:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        YoutubePlayer(
          controller: _youtubeController,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          progressColors: const ProgressBarColors(
            playedColor: Colors.blue,
            handleColor: Colors.blueAccent,
          ),
          onReady: () {
            // Optional: You can add logic when player is ready
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

 @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Event Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        actions: [
          if (widget.isOwner)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Edit functionality if needed
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventData.eventName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: isUpdatingInterest ? null : _handleInterest,
              style: ElevatedButton.styleFrom(
                backgroundColor: isInterested ? Colors.green : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: isUpdatingInterest
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isInterested ? 'Interested ✓' : 'I\'m Interested'),
            ),
            SizedBox(height: 16),
            Text(widget.eventData.description, style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            if (widget.eventData.videoUrl != null && widget.eventData.videoUrl!.isNotEmpty) ...[
              _buildVideoSection(),
            ],
            SizedBox(height: 16),
            Text('Duration: ${widget.eventData.duration_minutes} minutes', 
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Date: ${widget.eventData.date}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Time: ${formatEventTime(widget.eventData.time)}', 
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Location: ${widget.eventData.location}', 
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            Container(
              height: 300,
              child: GoogleMap(
                onMapCreated: (controller) => mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: eventLocation,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('eventLocation'),
                    position: eventLocation,
                    infoWindow: InfoWindow(title: widget.eventData.location),
                  ),
                },
              ),
            ),
            
            // Owner-specific video URL controls at the bottom
            if (widget.isOwner) ...[
              SizedBox(height: 24),
              Text('Manage Video URL:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: videoUrlController,
                decoration: InputDecoration(
                  labelText: 'Video URL',
                  hintText: 'https://example.com/video',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: isUpdatingVideoUrl ? null : _updateVideoUrl,
                child: isUpdatingVideoUrl
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Update Video URL'),
              ),
              SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}