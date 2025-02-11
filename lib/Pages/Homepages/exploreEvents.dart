import 'package:flutter/material.dart';
import 'package:fest_app/models/event.dart';
import 'package:fest_app/widgets/section_title.dart';
import 'package:fest_app/widgets/event_list.dart';
import 'package:fest_app/widgets/add_event_dialog.dart';

class ExploreEvents extends StatefulWidget {
  const ExploreEvents({super.key});

  @override
  _ExploreEventsState createState() => _ExploreEventsState();
}

class _ExploreEventsState extends State<ExploreEvents> {
  final List<Event> ongoingEvents = [
    Event(
        name: "Tech Symposium 2025",
        date: "Feb 10, 2025",
        colors: [Colors.orange, Colors.deepOrange]),
    Event(
        name: "AI & ML Workshop",
        date: "Feb 15, 2025",
        colors: [Colors.blue, Colors.indigo]),
  ];

  final List<Event> upcomingEvents = [
    Event(
        name: "Cybersecurity Conference",
        date: "March 5, 2025",
        colors: [Colors.green, Colors.teal]),
    Event(
        name: "Cloud Computing Summit",
        date: "March 20, 2025",
        colors: [Colors.purple, Colors.deepPurple]),
  ];

  void _addNewEvent(Event event) {
    setState(() {
      upcomingEvents.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddEventDialog(context, _addNewEvent),
          )
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: "Ongoing Events"),
              EventList(events: ongoingEvents),
              const SizedBox(height: 20),
              const SectionTitle(title: "Upcoming Events"),
              EventList(events: upcomingEvents),
            ],
          ),
        ),
      ),
    );
  }
}
