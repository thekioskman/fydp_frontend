import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> eventData;

  EventDetailPage({required this.eventData});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late GoogleMapController mapController;
  late LatLng eventLocation;

  @override
  void initState() {
    super.initState();
    // Assuming the JSON contains 'latitude' and 'longitude' fields
    eventLocation = LatLng(
      widget.eventData['latitude'],
      widget.eventData['longitude'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${widget.eventData['title']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Description: ${widget.eventData['description']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Duration: ${widget.eventData['duration']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Date: ${widget.eventData['date']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Time: ${widget.eventData['time']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Location: ${widget.eventData['location']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            Container(
              height: 300,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: eventLocation,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('eventLocation'),
                    position: eventLocation,
                    infoWindow: InfoWindow(
                      title: widget.eventData['location'],
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example function to fetch event data from the backend
Future<Map<String, dynamic>> fetchEventData(String eventId) async {
  final response = await http.get(Uri.parse('https://your-backend-api.com/events/$eventId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load event data');
  }
}

// Example usage in your app
class EventPage extends StatelessWidget {
  final String eventId;

  EventPage({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchEventData(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data found'));
        } else {
          return EventDetailPage(eventData: snapshot.data!);
        }
      },
    );
  }
}