import 'package:flutter/material.dart';
import 'package:frontend/profile/profilemain.dart';
import '../../club/event.dart';
import '../../login/login.dart'; // TODO: remove later


class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({super.key});

  @override
  _UpcomingEventsPageState createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  final Event mostRecentEvent = Event(
      eventName: "Dance Battle Night",
      date: "Feb 10, 2025",
      time: "7:00 PM",
      location: "E7 2nd floor",
      eventUrl: "/" // replace...?
      ); // Retrieve this from backend!

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileMainPage()),
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

        // Event Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Background color of the button
              borderRadius: BorderRadius.circular(12), // Rounded corners
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
                        mostRecentEvent.eventName,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6), // Space between elements
                      Text(
                        "Date: ${mostRecentEvent.date} @ ${mostRecentEvent.time}",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Location: ${mostRecentEvent.location}",
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
                        shape: BoxShape.circle, // Makes the button round
                        color: Colors.blue, // Background color of the button
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage(title: "Login from club")) // TODO: fix this later with the event page, get event page by event name! -> event ID...?
                          );
                        },
                        color: Colors.blue,
                        icon: Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
