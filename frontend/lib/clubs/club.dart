import 'package:flutter/material.dart';

class Club {
  final int id;
  final String name;
  final String description;
  final String clubTag;
  final String pageRoute;
  final Color? color;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.clubTag,
    required this.pageRoute,
    this.color,
  });

  // Factory method to create a Club from JSON response
  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? "No description available",
      clubTag: json['club_tag'],
      pageRoute: "/home", // TODO: For now, redirect to home
      color: _getColorFromTag(json['club_tag']),
    );
  }

  static Color _getColorFromTag(String clubTag) {
    switch (clubTag) {
      case "UWHH":
        return Colors.blue;
      case "Origins":
        return Colors.green;
      case "Haebeat":
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
