import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'event.dart'; // Assuming this is your Event class

class EventDetailPage extends StatefulWidget {
  final Event eventData;

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
      widget.eventData.latitude,
      widget.eventData.longitude,
    );

  }

  String formatEventTime(String time) {
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time"); // Add a dummy date
      return DateFormat.jm().format(parsedTime); // Format as "7 AM", "8 PM", etc.
    } catch (e) {
      print("Error formatting time: $time");
      return time; // Fallback to original time
    }
  }


  @override
  Widget build(BuildContext context) {
    // Convert the event time to local time


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
              'Title: ${widget.eventData.eventName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Description: ${widget.eventData.description}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Duration: ${widget.eventData.duration_minutes} minutes',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Date: ${widget.eventData.date}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Time: ${formatEventTime(widget.eventData.time)}', // Display the converted local time
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Location: ${widget.eventData.location}',
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
                      title: widget.eventData.location,
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