import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fest_app/collections/event.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/sectionTitle.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/eventList.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/addEventDialog.dart';
import 'package:fest_app/pages/Fests/festTemplatePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreEvents extends StatefulWidget {
  const ExploreEvents({super.key});

  @override
  _ExploreEventsState createState() => _ExploreEventsState();
}

class _ExploreEventsState extends State<ExploreEvents> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The user will be cached....
  late Future<DocumentSnapshot> _user;
  late bool _isAdmin;
  late Map<String, dynamic> _userData;
  @override
  void initState() {
    super.initState();
    _user = _fetchUser();
  }

  Future<DocumentSnapshot> _fetchUser() async {
    try {
      return await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .get();
    } catch (e) {
      throw Exception("Failed to load user: $e");
    }
  }

  final List<Event> ongoingEvents = [
    Event(
      name: "Tech Symposium 2025",
      date: "Feb 10, 2025",
      colors: [Colors.orange, Colors.deepOrange],
      navigateTo: TemplatePage(title: "Tech Symposium 2025"), // Pass title
    ),
    Event(
      name: "AI & ML Workshop",
      date: "Feb 15, 2025",
      colors: [Colors.blue, Colors.indigo],
      navigateTo: TemplatePage(title: "AI & ML Workshop"), // Pass title
    ),
  ];

  final List<Event> upcomingEvents = [
    Event(
      name: "Cybersecurity Conference",
      date: "March 5, 2025",
      colors: [Colors.green, Colors.teal],
      navigateTo: TemplatePage(title: "Cybersecurity Conference"), // Pass title
    ),
    Event(
      name: "Cloud Computing Summit",
      date: "March 20, 2025",
      colors: [Colors.purple, Colors.deepPurple],
      navigateTo: TemplatePage(title: "Cloud Computing Summit"), // Pass title
    ),
  ];

  void _addNewEvent(Event event) {
    setState(() {
      upcomingEvents.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          _userData = snapshot.data!.data() as Map<String, dynamic>;
          _isAdmin = _userData['admin'] ?? false;
        } else
          _isAdmin = false;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Events",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.deepPurple,
            actions: [
              if (_isAdmin)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => showAddEventDialog(context, _addNewEvent),
                ),
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
      },
    );
  }
}
