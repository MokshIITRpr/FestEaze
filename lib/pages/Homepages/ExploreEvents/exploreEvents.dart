import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fest_app/collections/event.dart';
import 'package:fest_app/data.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/sectionTitle.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/eventList.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/addEventDialog.dart';
import 'package:fest_app/pages/Fests/festTemplatePage.dart';

class ExploreEvents extends StatefulWidget {
  const ExploreEvents({super.key});

  @override
  _ExploreEventsState createState() => _ExploreEventsState();
}

class _ExploreEventsState extends State<ExploreEvents> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserData _userData = UserData();
  late Future<DocumentSnapshot> _user;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    _user = _userData.getUser(); // Get cached user data
    setState(() {}); // Refresh UI
  }

  Stream<Map<String, List<Event>>> _fetchEvents() {
    return _firestore.collection('fests').snapshots().map((snapshot) {
      List<Event> pastEvents = [];
      List<Event> ongoingEvents = [];
      List<Event> upcomingEvents = [];

      DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime startDate = (data['startDate'] as Timestamp).toDate();
        DateTime endDate = (data['endDate'] as Timestamp).toDate();

        Event event = Event(
          name: data['title'] ?? 'Unnamed Event',
          date:
              "${startDate.toLocal().toString().split(' ')[0]} - ${endDate.toLocal().toString().split(' ')[0]}",
          colors: [
            Colors.blueAccent.withOpacity(0.9),
            Colors.lightBlue.withOpacity(0.7)
          ],
          navigateTo: TemplatePage(
            title: data['title'] ?? 'Unnamed Event',
            docId: doc.id,
          ),
        );

        if (endDate.isBefore(now)) {
          pastEvents.add(event);
        } else if (startDate.isBefore(now) && endDate.isAfter(now)) {
          ongoingEvents.add(event);
        } else {
          upcomingEvents.add(event);
        }
      }

      return {
        "Past Events": pastEvents,
        "Ongoing Events": ongoingEvents,
        "Upcoming Events": upcomingEvents,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          _isAdmin = userData['admin'] ?? false;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Events",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: const Color.fromARGB(255, 84, 91, 216),
            actions: [
              if (_isAdmin)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => showAddEventDialog(context),
                ),
            ],
          ),
          backgroundColor: Colors.grey[200],
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<Map<String, List<Event>>>(
              stream: _fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No events available."));
                }

                Map<String, List<Event>> eventsMap = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eventsMap["Ongoing Events"]!.isNotEmpty) ...[
                        const SectionTitle(title: "Ongoing Events"),
                        EventList(events: eventsMap["Ongoing Events"]!),
                      ],
                      if (eventsMap["Upcoming Events"]!.isNotEmpty) ...[
                        const SectionTitle(title: "Upcoming Events"),
                        EventList(events: eventsMap["Upcoming Events"]!),
                      ],
                      if (eventsMap["Past Events"]!.isNotEmpty) ...[
                        const SectionTitle(title: "Past Events"),
                        EventList(events: eventsMap["Past Events"]!),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
