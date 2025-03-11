import 'package:flutter/material.dart';

class Event {
  final String eventName;
  final String date;
  final String time;
  final String location;
  final String eventUrl; // url to this event

  Event({
    Key? key,
    required this.eventName,
    required this.date,
    required this.time,
    required this.location,
    required this.eventUrl,
  });

  // Factory method to create an event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventName: json['title'] ?? 'Unknown Event',
      date: json['date'] ?? 'Unknown Date',
      time: json['time'] ?? 'Unknown Time',
      location: json['location'] ?? 'Unknown Location',
      eventUrl: '/', // Default to home
    );
  }
}
