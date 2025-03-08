import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/autoImageSlider.dart';
import './widgets/textFieldSection.dart';
import './utils/database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fest_app/data.dart';

class TemplatePage extends StatefulWidget {
  final String title;
  final String docId; // Accept docId

  const TemplatePage({super.key, required this.title, required this.docId});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _proniteController = TextEditingController();
  final TextEditingController _subEventsController = TextEditingController();
  final TextEditingController _searchController =
      TextEditingController(); // Search controller
  bool isEditing = false;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserData _userData = UserData();
  late Future<DocumentSnapshot> _user;
  bool _isAdmin = false;

  final List<String> _imagePaths = [
    'assets/aarohan.jpg',
    'assets/zeitgeist.jpeg',
    'assets/advitiya.jpeg',
    'assets/sponsor.jpeg',
  ];

  List<DocumentReference> proniteEvents = [];
  List<DocumentReference> subEventsList = [];
  List<DocumentReference> filteredEvents =
      []; // For filtered events based on search query

  @override
  void initState() {
    super.initState();
    _fetchText();
    _fetchUserData();
    filteredEvents = proniteEvents;
  }

  Future<void> _fetchUserData() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('fests')
        .doc(widget.docId) // Use dynamic docId
        .get();

    if (docSnapshot.exists) {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          bool a1 = userData['admin'] ?? false;
          bool a2 = docSnapshot['manager'].contains(userData['email']) ?? false;

          setState(() {
            _isAdmin = (a1 || a2);
            // print(_isAdmin);
          });
        }
      }
    }
  }

  Future<void> _fetchText() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('fests')
        .doc(widget.docId) // Use dynamic docId
        .get();

    if (docSnapshot.exists) {
      setState(() {
        _aboutController.text = docSnapshot['about'] ?? '';
        proniteEvents =
            List<DocumentReference>.from(docSnapshot['pronite'] ?? []);
        subEventsList =
            List<DocumentReference>.from(docSnapshot['subEvents'] ?? []);
        filteredEvents = subEventsList; // Initial events list
      });
    }
  }

  // This function filters the events based on the search query
  Future<void> _filterEvents(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredEvents = subEventsList; // If query is empty, show all events
      });
      return;
    }

    List<DocumentReference> filteredList = [];

    for (var eventRef in subEventsList) {
      var eventSnapshot = await eventRef.get();
      // Check if the document exists and its data is not null
      if (!eventSnapshot.exists || eventSnapshot.data() == null) {
        continue;
      }
      var eventData = eventSnapshot.data() as Map<String, dynamic>;
      String eventName = (eventData['eventName'] ?? '').toLowerCase();
      if (eventName.contains(query.toLowerCase())) {
        filteredList.add(eventRef);
      }
    }

    setState(() {
      filteredEvents = filteredList;
    });
  }

  Future<void> updateText(String field, String text) async {
    await updateDataInFirestore(
      docId: widget.docId, // Use dynamic docId
      field: field,
      text: text,
    );
    setState(() {
      isEditing = false;
    });
  }

  void _addEvent(String field) {
    showEventDialog(context, field, widget.docId, setState, _fetchText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
            255, 84, 91, 216), // Black background for app bar
        title: Text(
          widget.title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoImageSlider(imagePaths: _imagePaths),
                const SizedBox(height: 20),
                TextFieldSection(
                  title: "About",
                  controller: _aboutController,
                  isEditing: isEditing,
                  isAdmin: _isAdmin,
                  onEdit: () {
                    if (isEditing) {
                      updateText('about', _aboutController.text);
                    }
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                ),
                const SizedBox(height: 20),
                buildEditableSection("Flagship Events", _proniteController,
                    'pronite', proniteEvents),

                const SizedBox(height: 20),
                buildEventList(proniteEvents), // Display filtered events
                const SizedBox(height: 20),
                buildEditableSection("Explore Club Events",
                    _subEventsController, 'subEvents', subEventsList),
                const SizedBox(height: 20),
                // Search bar for searching events
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Events',
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.black), // White icon
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(
                            0.2), // Slightly transparent white background
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  onChanged: (query) {
                    _filterEvents(query); // Filter events as the user types
                  },
                ),
                buildEventList(filteredEvents),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableSection(String title, TextEditingController controller,
      String field, List<DocumentReference> eventList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            if (_isAdmin)
              IconButton(
                icon: const Icon(Icons.add,
                    color:
                        Color.fromRGBO(30, 215, 96, 1)), // Spotify Green color
                onPressed: () {
                  if (isEditing) {
                    updateText(field, controller.text);
                  }
                  _addEvent(field);
                },
              )
          ],
        ),
      ],
    );
  }

  Widget buildEventList(List<DocumentReference> eventList) {
    return eventList.isNotEmpty
        ? SizedBox(
            height: 250, // Fixed height for square cards
            child: ListView(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              children: eventList
                  .map((eventRef) => FutureBuilder<DocumentSnapshot>(
                        future: eventRef.get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasData && snapshot.data!.exists) {
                            var eventData =
                                snapshot.data!.data() as Map<String, dynamic>;

                            // Convert Timestamp to String (using DateFormat)
                            String eventName =
                                eventData['eventName'] ?? 'No title';
                            String venue = eventData['venue'] ?? 'Unknown';

                            // Handle Timestamp fields
                            Timestamp timestampDate =
                                eventData['date'] ?? Timestamp.now();
                            Timestamp timestampStartTime =
                                eventData['startTime'] ?? Timestamp.now();
                            Timestamp timestampEndTime =
                                eventData['endTime'] ?? Timestamp.now();

                            // Convert Timestamp to DateTime
                            DateTime date = timestampDate.toDate();
                            DateTime startTime = timestampStartTime.toDate();
                            DateTime endTime = timestampEndTime.toDate();

                            // Format the date and time
                            String formattedDate =
                                DateFormat('dd-MM-yyyy').format(date);
                            String formattedStartTime =
                                DateFormat('HH:mm').format(startTime);
                            String formattedEndTime =
                                DateFormat('HH:mm').format(endTime);

                            String timeRange =
                                '$formattedStartTime - $formattedEndTime';
                            return Container(
                              width: 200, // Fixed width for square-shaped card
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Card(
                                elevation: 4,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Image at the top of the card
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12)),
                                      child: Image.asset(
                                        'assets/iitrpr.jpeg',
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.broken_image,
                                              size: 100, color: Colors.red);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            eventName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 20,
                                                  color: Colors.black),
                                              const SizedBox(width: 8),
                                              Text(
                                                ' $formattedDate',
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time,
                                                  size: 20,
                                                  color: Colors.black),
                                              const SizedBox(width: 8),
                                              Text(
                                                ' $timeRange',
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 20,
                                                  color: Colors.black),
                                              const SizedBox(width: 8),
                                              Text(
                                                ' $venue',
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ))
                  .toList(),
            ),
          )
        : const Center(child: Text('No events available.'));
  }
}
