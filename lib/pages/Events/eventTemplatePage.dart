import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fest_app/pages/Events/widgets/addAuth.dart';
import 'package:fest_app/pages/Fests/widgets/autoImageSlider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

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
  bool _isRegistered = false;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
      });

      // Check if the current user is already registered
      User? user = _auth.currentUser;
      if (user != null && eventData != null) {
        List registrations = eventData!['registrations'] ?? [];
        bool alreadyRegistered =
            registrations.any((reg) => reg['uid'] == user.uid);
        setState(() {
          _isRegistered = alreadyRegistered;
        });
      }
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event updated successfully!")),
    );
  }

  // Registration method with duplicate-check
  Future<void> _registerUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (_isRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have already registered to the event")),
        );
        return;
      }
      try {
        await _firestore.collection('events').doc(widget.eventRef.id).update({
          'registrations': FieldValue.arrayUnion([
            {'uid': user.uid, 'ispresent': false}
          ])
        });
        setState(() {
          _isRegistered = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
    }
  }

  // Method to show registration details in a popup dialog
  Future<void> _showRegistrationsDialog() async {
    List registrations = eventData?['registrations'] ?? [];
    List<Map<String, dynamic>> registrationsDetails = [];

    // Fetch user details for each registration
    for (var reg in registrations) {
      String uid = reg['uid'];
      bool isPresent = reg['ispresent'];
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Using "username" key; adjust if your user document key is different.
        String username = userData['username'] ?? "No Name";
        String email = userData['email'] ?? "No Email";
        registrationsDetails.add({
          'username': username,
          'email': email,
          'ispresent': isPresent,
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Registrations"),
          content: Container(
            width: double.maxFinite,
            child: registrationsDetails.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: registrationsDetails.length,
                    itemBuilder: (context, index) {
                      var regDetail = registrationsDetails[index];
                      return ListTile(
                        title: Text(regDetail['username']),
                        subtitle: Text(regDetail['email']),
                        trailing: Text(
                          regDetail['ispresent'] ? "Present" : "Absent",
                          style: TextStyle(
                            color: regDetail['ispresent']
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text("No registrations found")),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  // Method to scan QR code and mark user as present
  Future<void> _scanQRCode() async {
    try {
      // This uses the barcode_scan2 package to scan the QR code.
      var scanResult = await BarcodeScanner.scan();
      String scannedUID = scanResult.rawContent;
      if (scannedUID.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No QR code data found")),
        );
        return;
      }
      // Read current registrations from eventData.
      List registrations = eventData?['registrations'] ?? [];
      bool found = false;
      for (int i = 0; i < registrations.length; i++) {
        if (registrations[i]['uid'] == scannedUID) {
          // Update the ispresent field for the matching registration.
          registrations[i]['ispresent'] = true;
          found = true;
          break;
        }
      }
      if (found) {
        await _firestore.collection('events').doc(widget.eventRef.id).update({
          'registrations': registrations,
        });
        // Refresh the event data.
        await _fetchEventData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User presence marked.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not registered.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("QR scan failed: $e")),
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
    // Button styles: blue for not registered, green for registered.
    final ButtonStyle blueStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 84, 91, 216),
    );
    final ButtonStyle greenStyle =
        ElevatedButton.styleFrom(backgroundColor: Colors.green);

    return Scaffold(
      appBar: _isLoading
          ? AppBar()
          : AppBar(
              backgroundColor: const Color.fromARGB(255, 84, 91, 216),
              title: Text(
                eventData!['eventName'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              actions: [
                // QR Scanner icon (only visible to admins and event managers)
                if (_isAdmin)
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    tooltip: "Scan QR Code",
                    onPressed: _scanQRCode,
                  ),
                // Registration details icon (visible to admins)
                if (_isAdmin)
                  IconButton(
                    icon: const Icon(Icons.list_alt, color: Colors.white),
                    tooltip: "View Registrations",
                    onPressed: _showRegistrationsDialog,
                  ),
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
                                    border: OutlineInputBorder()),
                              ),
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
                                            border: OutlineInputBorder())),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                        controller: _endTimeController,
                                        decoration: const InputDecoration(
                                            labelText: "End Time",
                                            border: OutlineInputBorder())),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 10),
                        _isPreviewMode || !_isAdmin
                            ? Text("📍 Venue: ${_venueController.text}")
                            : TextField(
                                controller: _venueController,
                                decoration: const InputDecoration(
                                    labelText: "Venue",
                                    border: OutlineInputBorder()),
                              ),
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
                        // If admin is editing, show the Save Changes button.
                        if (!_isPreviewMode && _isAdmin)
                          ElevatedButton(
                              onPressed: _updateEventData,
                              child: const Text("Save Changes")),
                        // Registration button (shown in preview mode or for non-admin users)
                        if (_isPreviewMode || !_isAdmin)
                          Center(
                            child: ElevatedButton(
                              style: _isRegistered ? greenStyle : blueStyle,
                              onPressed: () {
                                if (_isRegistered) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "You have already registered to the event")),
                                  );
                                } else {
                                  _registerUser();
                                }
                              },
                              child: Text(
                                _isRegistered ? "Registered" : "Register",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
