import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fest_app/pages/Events/widgets/addAuth.dart';
import 'package:fest_app/pages/Fests/widgets/autoImageSlider.dart';

class EventTemplatePage extends StatefulWidget {
  final String title;
  final bool isSuperAdmin;
  final DocumentReference eventRef;
  const EventTemplatePage({
    super.key,
    required this.title,
    required this.isSuperAdmin,
    required this.eventRef,
  });

  @override
  State<EventTemplatePage> createState() => _EventTemplatePageState();
}

class _EventTemplatePageState extends State<EventTemplatePage> {
  bool _isLoading = true;
  bool _isPreviewMode = false; // Track preview mode
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
        await _firestore.collection('events').doc(widget.eventRef.id).get();
    if (docSnapshot.exists) {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          bool a1 = widget.isSuperAdmin;
          bool a2 = false;
          try {
            a2 = docSnapshot['manager'].contains(userData['email']);
          } catch (e) {
            print(e);
          }
          setState(() {
            _isAdmin = a1 || a2;
          });
        }
      }
    }
  }

  Future<void> _fetchEventData() async {
    var docSnapshot =
        await _firestore.collection('events').doc(widget.eventRef.id).get();
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
    await _firestore.collection('events').doc(widget.eventRef.id).update({
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
    if (googleFormLink != null &&
        googleFormLink.isNotEmpty &&
        googleFormLink != "") {
      launchUrl(Uri.parse(googleFormLink));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No registration link available!")),
      );
    }
  }

  void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading
          ? AppBar()
          : AppBar(
              backgroundColor: const Color.fromARGB(255, 84, 91, 216),
              title: Text(eventData!['eventName'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              actions: [
                if (_isAdmin)
                  IconButton(
                    icon: Icon(
                        _isPreviewMode
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white),
                    onPressed: _togglePreviewMode,
                    tooltip: _isPreviewMode ? "Exit Preview" : "Preview Mode",
                  ),
                if (_isAdmin && !widget.isSuperAdmin)
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined,
                        color: Colors.white),
                    onPressed: () => showAuthDialog(
                        context, widget.eventRef.id, "volunteer"),
                    tooltip: "Add Volunteers",
                  ),
                if (widget.isSuperAdmin)
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined,
                        color: Colors.white),
                    onPressed: () =>
                        showAuthDialog(context, widget.eventRef.id, "manager"),
                    tooltip: "Add Manager",
                  ),
              ],
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
                        AutoImageSlider(imagePaths: [
                          'assets/aarohan.jpg',
                          'assets/zeitgeist.jpeg',
                          'assets/advitiya.jpeg',
                          'assets/sponsor.jpeg',
                        ]),
                        const SizedBox(height: 20),
                        Text(eventData!['eventName'],
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 10),
                        _isPreviewMode || !_isAdmin
                            ? Text("📅 Date: ${_dateController.text}")
                            : TextField(
                                controller: _dateController,
                                decoration: const InputDecoration(
                                    labelText: "Event Date",
                                    border: OutlineInputBorder())),
                        const SizedBox(height: 10),
                        _isPreviewMode || !_isAdmin
                            ? Text(
                                "⏰ Time: ${_startTimeController.text} - ${_endTimeController.text}")
                            : Row(
                                children: [
                                  Expanded(
                                      child: TextField(
                                          controller: _startTimeController,
                                          decoration: const InputDecoration(
                                              labelText: "Start Time",
                                              border: OutlineInputBorder()))),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: TextField(
                                          controller: _endTimeController,
                                          decoration: const InputDecoration(
                                              labelText: "End Time",
                                              border: OutlineInputBorder()))),
                                ],
                              ),
                        const SizedBox(height: 10),
                        _isPreviewMode || !_isAdmin
                            ? Text("📍 Venue: ${_venueController.text}")
                            : TextField(
                                controller: _venueController,
                                decoration: const InputDecoration(
                                    labelText: "Venue",
                                    border: OutlineInputBorder())),

                        const SizedBox(height: 20),
                        if (_isPreviewMode || !_isAdmin)
                          const Text(
                            "📝 Event Description:",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),

                        const SizedBox(height: 10),

                        _isPreviewMode || !_isAdmin
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _descriptionController.text.isNotEmpty
                                      ? _descriptionController.text
                                      : "No description available",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              )
                            : TextField(
                                controller: _descriptionController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  labelText: "Event Description",
                                  border: OutlineInputBorder(),
                                ),
                              ),

                        const SizedBox(height: 20),

// If admin and NOT in preview mode, allow editing the Google Form link
                        if (_isAdmin && !_isPreviewMode)
                          TextField(
                            controller: _googleFormController,
                            decoration: const InputDecoration(
                              labelText: "Google Form Link",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (!_isPreviewMode && _isAdmin)
                          ElevatedButton(
                              onPressed: _updateEventData,
                              child: const Text("Save Changes")),
                        if (_isPreviewMode || !_isAdmin)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "🔗 Registration Link:",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              eventData?['googleFormLink'] != null &&
                                      eventData!['googleFormLink'].isNotEmpty
                                  ? TextButton(
                                      onPressed: _launchGoogleForm,
                                      child: const Text(
                                          "Click here to Register",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 16)),
                                    )
                                  : const Text(
                                      "No registration link available!",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 16)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
