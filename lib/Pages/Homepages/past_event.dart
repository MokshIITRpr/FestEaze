import 'package:flutter/material.dart';
import 'package:fest_app/models/event.dart';
import 'package:fest_app/widgets/event_list.dart';
import 'package:fest_app/Pages/festTemplatePage.dart';

class PastEvents extends StatelessWidget {
  const PastEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Event> pastEvents = [
      Event(
          name: "Zeitgeist 2024",
          date: "Oct 17, 2024 - Oct 19, 2024",
          colors: [Colors.green, Colors.teal],
          navigateTo: TemplatePage()),
      Event(
          name: "Advitiya 2024",
          date: "Feb 17, 2024 - Feb 19, 2024",
          colors: [Colors.purple, Colors.deepPurple],
          navigateTo: TemplatePage()),
      Event(
          name: "Aarohan 2024",
          date: "March 20, 2024 - March 23, 2024",
          colors: [
            const Color.fromARGB(255, 195, 201, 18),
            const Color.fromARGB(255, 148, 152, 89)
          ],
          navigateTo: TemplatePage()),
      Event(
          name: "General Championship 2025",
          date: "Jan 20, 2024 - Feb 19, 2024",
          colors: [
            const Color.fromARGB(255, 3, 68, 234),
            const Color.fromARGB(255, 70, 74, 114)
          ],
          navigateTo: TemplatePage()),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Past Events',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set text color to white
            fontSize: 20, // Optional: Adjust font size for better visibility
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adds padding to the sides
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EventList(events: pastEvents),
          ],
        ),
      ),
    );
  }
}
