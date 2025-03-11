import 'package:flutter/material.dart';
import '../../clubs/event.dart';
import 'package:intl/intl.dart';

class UpcomingEventsMainPage extends StatefulWidget {
  final List<Event> events;

  const UpcomingEventsMainPage({super.key, required this.events});

  @override 
  _UpcomingEventsMainPageState createState() => _UpcomingEventsMainPageState();
}

class _UpcomingEventsMainPageState extends State<UpcomingEventsMainPage> {
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
    return Scaffold(
      appBar: AppBar(title: Text("All Upcoming Events")),
      body: widget.events.isEmpty
        ? const Center(child: Text("No upcoming events"))
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List of Upcoming Events
            Expanded(
              child: ListView.builder(
                itemCount: widget.events.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
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
                                  widget.events[index].eventName,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Date: ${widget.events[index].date} @ ${formatEventTime(widget.events[index].time)}",
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Location: ${widget.events[index].location}",
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
                                  // TODO: Replace with event details page
                                },
                                color: Colors.blue,
                                icon: Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  );
                }, 
              ),
            ),
          ],
        )
    );
  }
}