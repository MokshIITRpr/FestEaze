import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fest_app/collections/event.dart';
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

  late Future<DocumentSnapshot> _user;
  bool _isAdmin = false;

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

  Stream<List<Event>> _fetchEvents() {
    return _firestore.collection('fests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Event(
          name: data['title'] ?? 'Unnamed Event',
          date:
              "${(data['startDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0]} - ${(data['endDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0]}",
          colors: [
            Colors.blueAccent.withOpacity(0.9),
            Colors.lightBlue.withOpacity(0.7)
          ],
          navigateTo: TemplatePage(
              title: data['title'] ?? 'Unnamed Event',
              docId: doc.id), // Pass docId
        );
      }).toList();
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
            backgroundColor: Colors.deepPurple,
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
            child: StreamBuilder<List<Event>>(
              stream: _fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No events available."));
                }

                List<Event> events = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: "Upcoming Events"),
                      EventList(events: events),
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
