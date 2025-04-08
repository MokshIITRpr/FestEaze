import 'package:fest_app/snackbar.dart';
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
  bool isVolunteer = false;
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
          bool a3 = false;
          try {
            a2 = docSnapshot['manager'].contains(userData['email']);
          } catch (e) {
            print(e);
          }
          try {
            a3 = docSnapshot['volunteers'].contains(userData['email']);
          } catch (e) {
            print(e);
          }
          setState(() {
            isVolunteer = a3;
          });
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

    // Using custom snackbar for success message.
    showCustomSnackBar(
      context,
      "Event updated successfully!",
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  // Registration method with duplicate-check.
  Future<void> _registerUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (_isRegistered) {
        showCustomSnackBar(
          context,
          "You have already registered to the event",
          backgroundColor: Colors.green,
          icon: Icons.info,
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
        showCustomSnackBar(
          context,
          "Registered successfully!",
          backgroundColor: const Color.fromARGB(255, 84, 91, 216),
          icon: Icons.check_circle,
        );
      } catch (e) {
        showCustomSnackBar(
          context,
          "Registration failed: $e",
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } else {
      showCustomSnackBar(
        context,
        "User not logged in!",
        backgroundColor: Colors.red,
        icon: Icons.warning,
      );
    }
  }

  // Improved registration dialog with themed header and serial numbering.
  Future<void> _showRegistrationsDialog() async {
    // Refresh event data to get the latest registrations.
    await _fetchEventData();
    // Safely retrieve the registrations list from eventData.
    List registrations =
        (eventData != null && eventData!['registrations'] != null)
            ? eventData!['registrations']
            : [];
    List<Map<String, dynamic>> registrationsDetails = [];

    // Fetch user details for each registration.
    for (var reg in registrations) {
      try {
        String uid = reg['uid'] ?? "";
        bool isPresent = reg['ispresent'] ?? false;
        if (uid.isNotEmpty) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            String username = userData['username'] ?? "No Name";
            String email = userData['email'] ?? "No Email";
            registrationsDetails.add({
              'username': username,
              'email': email,
              'ispresent': isPresent,
            });
          }
        }
      } catch (e) {
        print("Error fetching user for registration: $e");
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 84, 91, 216),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                "Registrations (${registrationsDetails.length})",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: SizedBox(
              height: 300,
              child: registrationsDetails.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      itemCount: registrationsDetails.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade300,
                        height: 10,
                      ),
                      itemBuilder: (context, index) {
                        var regDetail = registrationsDetails[index];
                        String username = regDetail['username'] ?? "No Name";
                        String email = regDetail['email'] ?? "No Email";
                        bool isPresent = regDetail['ispresent'] ?? false;
                        return ListTile(
                          leading: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: Text(
                            username,
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            email,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text(
                            isPresent ? "Present" : "Absent",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isPresent ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                    )
                  : SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          "No registrations found",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 84, 91, 216),
              ),
              child: const Text(
                "Close",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        );
      },
    );
  }

  // Method to scan QR code and mark user as present.
  Future<void> _scanQRCode() async {
    try {
      var scanResult = await BarcodeScanner.scan();
      String scannedUID = scanResult.rawContent;
      if (scannedUID.isEmpty) {
        showCustomSnackBar(
          context,
          "No QR code data found",
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
        return;
      }
      List registrations = eventData?['registrations'] ?? [];
      bool found = false;
      for (int i = 0; i < registrations.length; i++) {
        if (registrations[i]['uid'] == scannedUID) {
          registrations[i]['ispresent'] = true;
          found = true;
          break;
        }
      }
      if (found) {
        await _firestore
            .collection('events')
            .doc(widget.eventRef.id)
            .update({'registrations': registrations});
        await _fetchEventData();
        showCustomSnackBar(
          context,
          "User presence marked.",
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
        );
      } else {
        showCustomSnackBar(
          context,
          "User not registered.",
          backgroundColor: const Color.fromARGB(255, 84, 91, 216),
          icon: Icons.info,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        context,
        "QR scan failed: $e",
        backgroundColor: Colors.red,
        icon: Icons.error,
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
                if (_isAdmin || isVolunteer)
                  IconButton(
                    icon:
                        const Icon(Icons.qr_code_scanner, color: Colors.white),
                    tooltip: "Scan QR Code",
                    onPressed: _scanQRCode,
                  ),
                if (_isAdmin || isVolunteer)
                  IconButton(
                    icon: const Icon(Icons.list_alt, color: Colors.white),
                    tooltip: "View Registrations",
                    onPressed: _showRegistrationsDialog,
                  ),
                if (_isAdmin)
                  IconButton(
                    icon: Icon(
                      _isPreviewMode ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
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
                        Text(
                          eventData!['eventName'],
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
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
                        if (!_isPreviewMode && _isAdmin)
                          ElevatedButton(
                              onPressed: _updateEventData,
                              child: const Text("Save Changes")),
                        if (_isPreviewMode || !_isAdmin)
                          Center(
                            child: ElevatedButton(
                              style: _isRegistered ? greenStyle : blueStyle,
                              onPressed: () {
                                if (_isRegistered) {
                                  showCustomSnackBar(
                                    context,
                                    "You have already registered to the event",
                                    backgroundColor: Colors.green,
                                    icon: Icons.info,
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
