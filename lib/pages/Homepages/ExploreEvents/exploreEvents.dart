import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fest_app/collections/event.dart';
import 'package:fest_app/data.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/sectionTitle.dart';
import 'package:fest_app/pages/Fests/festTemplatePage.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/addEventDialog.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/widgets/addAuth.dart';
import 'package:intl/intl.dart';
import 'package:fest_app/snackbar.dart';
import 'package:fest_app/messages/messages.dart';

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
  final bool _isLoggedIn = FirebaseAuth.instance.currentUser != null;

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

        // Format startDate and endDate as dd/MM/yyyy
        String formattedStartDate =
            DateFormat('dd/MM/yyyy').format(startDate.toLocal());
        String formattedEndDate =
            DateFormat('dd/MM/yyyy').format(endDate.toLocal());

        Event event = Event(
          name: data['title'] ?? 'Unnamed Event',
          date: "$formattedStartDate - $formattedEndDate",
          colors: [
            Colors.blueAccent.withOpacity(0.9),
            Colors.deepPurple.withOpacity(0.7)
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

  /// Builds a card widget for the given event.
  Widget _buildEventCard(Event event, bool ongoingEvent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            if (_isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => event.navigateTo),
              );
            } else {
              showCustomSnackBar(context, loginToUse);
            }
          },
          child: Container(
            height: 150.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              image: DecorationImage(
                image: AssetImage('assets/iitrpr.jpeg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.date,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // Icon for adding a manager for the event
                if (ongoingEvent && _isAdmin)
                  GestureDetector(
                    onTap: () => showAuthDialog(context, event.name),
                    child: Icon(
                      Icons.person_add_alt_1_outlined,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a list view of event cards.
  Widget _buildEventList(List<Event> events, bool ongoingEvent) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) =>
          _buildEventCard(events[index], ongoingEvent),
    );
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

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "Events",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color.fromARGB(255, 84, 91, 216),
              actions: [
                if (_isAdmin)
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => showAddEventDialog(context),
                  ),
              ],
              elevation: 0,
            ),
            backgroundColor: Colors.grey[200],
            body: Column(
              children: [
                // Floating Tab Bar just below the AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 84, 91, 216),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: EdgeInsets.zero,
                      labelColor: const Color.fromARGB(255, 255, 255, 255),
                      unselectedLabelColor: const Color.fromARGB(255, 168, 166, 166),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                      indicator: BoxDecoration(
                        color: const Color.fromARGB(255, 216, 214, 214)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      tabs: const [
                        Tab(text: "Ongoing"),
                        Tab(text: "Upcoming"),
                        Tab(text: "Past"),
                      ],
                    ),
                  ),
                ),

                // The tab pages
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: StreamBuilder<Map<String, List<Event>>>(
                      stream: _fetchEvents(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("No Events Currently!"));
                        }
                        final eventsMap = snapshot.data!;
                        return TabBarView(
                          children: [
                            eventsMap["Ongoing Events"]!.isNotEmpty
                                ? _buildEventList(
                                    eventsMap["Ongoing Events"]!, true)
                                : const Center(
                                    child:
                                        Text("No Ongoing Events available.")),
                            eventsMap["Upcoming Events"]!.isNotEmpty
                                ? _buildEventList(
                                    eventsMap["Upcoming Events"]!, true)
                                : const Center(
                                    child:
                                        Text("No Upcoming Events available.")),
                            eventsMap["Past Events"]!.isNotEmpty
                                ? _buildEventList(
                                    eventsMap["Past Events"]!, false)
                                : const Center(
                                    child: Text("No Past Events available.")),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
