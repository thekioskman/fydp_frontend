import 'package:flutter/material.dart';
import 'package:frontend/profile/pages/upcomingeventsmain.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../club/event.dart';
import '../../login/login.dart'; // TODO: remove later
import 'package:shared_preferences/shared_preferences.dart'; // For caching data
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For decoding JSON
import 'package:intl/intl.dart';

class UpcomingEventsPage extends StatefulWidget {
  final int userId;

  const UpcomingEventsPage({super.key, required this.userId});

  @override
  UpcomingEventsPageState createState() => UpcomingEventsPageState();
}

class UpcomingEventsPageState extends State<UpcomingEventsPage> {
  List<Event> allEvents = [];
  Event? mostRecentEvent; // Store upcoming event
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchUpcomingEvent();
  }

  /// **Fetch User's Interested Events and Get the Most Upcoming Event**
  Future<void> fetchUpcomingEvent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (widget.userId == -1) throw Exception("Invalid user ID");

      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
      final response = await http.get(Uri.parse('$apiUrl/user/${widget.userId}/interested'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> events = data['events'];

        // Parse the current date & time
        DateTime now = DateTime.now();

        // Filter only future events
        List<Event> futureEvents = events
            .map((event) => Event.fromJson(event)) // Convert to `Event` objects
            .where((event) {
              DateTime eventDateTime = DateTime.parse("${event.date} ${event.time}"); 
              return eventDateTime.isAfter(now); // Only keep future events
            })
            .toList();

        if (futureEvents.isNotEmpty) {
          setState(() {
            allEvents = futureEvents;
            mostRecentEvent = futureEvents.first; // Take the first valid upcoming event
          });
        } else {
          print("No upcoming events found.");
        }
      } else {
        throw Exception("Failed to fetch events");
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
      print("Error fetching events: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// **Format event time into 12-hour AM/PM format**
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
    return Column(
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 16.0, left: 16.0),
                child: Text(
                  "Upcoming Events",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                )),
            GestureDetector(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                  context, 
                  screen: UpcomingEventsMainPage(events: allEvents), 
                  settings: RouteSettings(name: "UpcomingEventsMainPage"), // Define a route name
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  ">",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),

        // Show Loading Indicator
        if (isLoading)
          CircularProgressIndicator(),

        // Show Error Message
        if (hasError)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Failed to load events", style: TextStyle(color: Colors.red)),
          ),

        // Show Most Recent Event or No Events Message
        if (!isLoading && !hasError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: mostRecentEvent != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Event Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mostRecentEvent!.eventName,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Date: ${mostRecentEvent!.date} @ ${formatEventTime(mostRecentEvent!.time)}",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Location: ${mostRecentEvent!.location}",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        // Arrow Button
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 10),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(), // TODO: Replace with event details page
                                  ),
                                );
                              },
                              color: Colors.blue,
                              icon: Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      "No upcoming events",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),
          ),
      ],
    );
  }
}
