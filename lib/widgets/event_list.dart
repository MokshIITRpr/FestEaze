import 'package:flutter/material.dart';
import '../models/event.dart';
import 'event_card.dart';

class EventList extends StatelessWidget {
  final List<Event> events;

  const EventList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return events.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return EventCard(event: events[index]);
            },
          )
        : const Text("No events available",
            style: TextStyle(color: Colors.grey));
  }
}
