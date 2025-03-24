import 'dart:ffi';

import 'package:flutter/material.dart';

class Event {
  final String eventName;
  final String description;
  final String date;
  final String time;
  final String location;
  final String eventUrl; // url to this event
  final double latitude;
  final double longitude;
  final int duration_minutes;
  final int id;


  Event({
    Key? key,
    required this.eventName,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.eventUrl,
    required this.latitude,
    required this.longitude,
    required this.duration_minutes,
    required this.id
  });

  // Factory method to create an event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventName: json['title'] ?? 'Unknown Event',
      description: json['description'] ?? "",
      date: json['date'] ?? 'Unknown Date',
      time: json['time'] ?? 'Unknown Time',
      duration_minutes: json["duration_minutes"] ?? "",
      location: json['location'] ?? 'Unknown Location',
      longitude: json['longitude'] ?? 0.0,
      latitude: json['latitude'] ?? 0.0,
      eventUrl: '/', // Default to home
      id : json['id'] ?? -1
    );
  }
}
