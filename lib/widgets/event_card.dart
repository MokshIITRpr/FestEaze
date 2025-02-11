import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: event.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          event.name,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Text(
          event.date,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      ),
    );
  }
}
