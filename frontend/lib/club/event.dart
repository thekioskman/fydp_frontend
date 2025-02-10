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
}
