import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fest_app/pages/Events/widgets/addAuth.dart';

class EventTemplatePage extends StatefulWidget {
  final String title;
  final String docId;
  final bool isSuperAdmin;

  const EventTemplatePage({
    super.key,
    required this.title,
    required this.docId,
    required this.isSuperAdmin,
  });

  @override
  State<EventTemplatePage> createState() => _EventTemplatePageState();
}

class _EventTemplatePageState extends State<EventTemplatePage> {
  bool _isLoading = true;
  Map<String, dynamic>? eventData;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAdmin = false;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _googleFormController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEventData();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    var docSnapshot =
        await _firestore.collection('events').doc(widget.docId).get();

    if (docSnapshot.exists) {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          bool a1 = widget.isSuperAdmin;
          bool a2 = docSnapshot['manager'].contains(userData['email']) ?? false;
          setState(() {
            _isAdmin = (a1 || a2);
          });
        }
      }
    }
  }

  Future<void> _fetchEventData() async {
    var docSnapshot =
        await _firestore.collection('events').doc(widget.docId).get();

    if (docSnapshot.exists) {
      setState(() {
        eventData = docSnapshot.data();
        _isLoading = false;

        _dateController.text = DateFormat('dd-MM-yyyy')
            .format((eventData!['date'] as Timestamp).toDate());
        _startTimeController.text = DateFormat('HH:mm')
            .format((eventData!['startTime'] as Timestamp).toDate());
        _endTimeController.text = DateFormat('HH:mm')
            .format((eventData!['endTime'] as Timestamp).toDate());
        _venueController.text = eventData!['venue'] ?? "";
        _descriptionController.text = eventData!['description'] ?? "";
        _googleFormController.text = eventData!['googleFormLink'] ?? "";
      });
    }
  }

  Future<void> _updateEventData() async {
    await _firestore.collection('events').doc(widget.docId).update({
      'date': Timestamp.fromDate(
          DateFormat('dd-MM-yyyy').parse(_dateController.text)),
      'startTime': Timestamp.fromDate(
          DateFormat('HH:mm').parse(_startTimeController.text)),
      'endTime': Timestamp.fromDate(
          DateFormat('HH:mm').parse(_endTimeController.text)),
      'venue': _venueController.text,
      'description': _descriptionController.text,
      'googleFormLink': _googleFormController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event updated successfully!")),
    );
  }

  void _launchGoogleForm() {
    String? googleFormLink = eventData?['googleFormLink'];
    if (googleFormLink != null && googleFormLink.isNotEmpty) {
      launchUrl(Uri.parse(googleFormLink));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No registration link available!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.isSuperAdmin)
              Text(
                "Add Event Manager",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (widget.isSuperAdmin)
              GestureDetector(
                onTap: () => showAuthDialog(context, widget.docId),
                child: const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventData == null
              ? const Center(child: Text("Event not found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventData!['eventName'] ?? "No Title",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _isAdmin
                            ? TextField(
                                controller: _dateController,
                                decoration: const InputDecoration(
                                  labelText: "Event Date",
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    _dateController.text,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 10),
                        _isAdmin
                            ? Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _startTimeController,
                                      decoration: const InputDecoration(
                                        labelText: "Start Time",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _endTimeController,
                                      decoration: const InputDecoration(
                                        labelText: "End Time",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${_startTimeController.text} - ${_endTimeController.text}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 10),
                        _isAdmin
                            ? TextField(
                                controller: _venueController,
                                decoration: const InputDecoration(
                                  labelText: "Venue",
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    _venueController.text,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 20),

                        Text(
                          "About",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // If admin, allow editing the description
                        _isAdmin
                            ? TextField(
                                controller: _descriptionController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  labelText: "Event Description",
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : Text(
                                _descriptionController.text,
                                style: const TextStyle(fontSize: 16),
                              ),

                        const SizedBox(height: 20),

                        if (_isAdmin)
                          TextField(
                            controller: _googleFormController,
                            decoration: const InputDecoration(
                              labelText: "Google Form Link",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        const SizedBox(height: 30),
                        // Check if the user is an admin
                        if (_isAdmin)
                          Center(
                            child: ElevatedButton(
                              onPressed: _updateEventData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Register button (for non-admins)
                        if (!_isAdmin)
                          Center(
                            child: ElevatedButton(
                              onPressed: _launchGoogleForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text("Register"),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
