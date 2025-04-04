import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fest_app/data.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart'; // For WidgetStateProperty
import 'package:fest_app/pages/Events/eventTemplatePage.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final _userData = UserData();
  String? qrData;
  String? userName;
  bool isLoading = true;
  bool _isHovered = false; // Tracks hover state for the logout button
  List<String> favs = [];
  bool _isAdmin = false;
  List<DocumentReference> favroiteEvents = [];

  final List<String> sponsorImages = [
    'assets/sponsor.jpeg',
    'assets/sponsor_2.jpeg',
    'assets/sponsor_3.jpg',
    'assets/sponsor_2.jpeg',
    'assets/sponsor_3.jpg',
    'assets/sponsor.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _loadQRData();
  }

  Future<void> _loadQRData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/loginScreen');
      return;
    }

    try {
      DocumentSnapshot userDoc = await _userData.getUser();
      List<String>? tempFav = _userData.getFavorites();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          qrData = userDoc['qrCodeData'];
          userName = userDoc['username'];
          favs = tempFav ?? [];
          _isAdmin = userDoc['admin'];
          isLoading = false;
          if (favs.isNotEmpty) {
            favroiteEvents = favs
                .map((id) =>
                    FirebaseFirestore.instance.collection('events').doc(id))
                .toList();
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching QR data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      _userData.clearCache();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/homeScreen');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed. Please try again!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background Sponsors - Fill the entire screen with repeated images
              Positioned.fill(
                child: Opacity(
                  opacity: 0.4,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        sponsorImages[index % sponsorImages.length],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              // Centered Content
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (favs.isNotEmpty) SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 84, 91, 216)
                              .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Your QR Code",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            isLoading
                                ? const CircularProgressIndicator()
                                : qrData != null
                                    ? QrImageView(
                                        data: qrData!,
                                        version: QrVersions.auto,
                                        size: 200.0,
                                        backgroundColor: Colors.white,
                                      )
                                    : const Text("No QR info"),
                            const SizedBox(height: 10),
                            if (userName != null)
                              Text(
                                "Hello, $userName!",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(height: 10),
                            const Text(
                              "Scan this QR code to get user details.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            // Wrap the logout button in a MouseRegion to detect hover events
                            MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  _isHovered = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _isHovered = false;
                                });
                              },
                              child: ElevatedButton(
                                onPressed: _logout,
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      // When the button is pressed, show the pressed effect
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.redAccent;
                                      }
                                      // Otherwise, use the hover state determined by the MouseRegion
                                      return _isHovered
                                          ? Colors.red.shade700
                                          : Colors.red;
                                    },
                                  ),
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              favs.isNotEmpty ? "Favorites" : "Add Favorites",
                              style: TextStyle(
                                fontFamily:
                                    'PlayfairDisplay', // Optional custom font
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black26,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                width: 8), // Space between text and icon
                            favs.isNotEmpty
                                ? Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 32,
                                  )
                                : Text(
                                    "😜",
                                    style: TextStyle(fontSize: 32),
                                  ),
                          ],
                        ),
                      ),
                      if (favs.isNotEmpty) buildEventList(favroiteEvents),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventList(List<DocumentReference> eventList) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: eventList.length,
      itemBuilder: (context, index) {
        DocumentReference eventRef = eventList[index];
        return FutureBuilder<DocumentSnapshot>(
          future: eventRef.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data!.exists) {
              var eventData = snapshot.data!.data() as Map<String, dynamic>;

              // Extract event details
              String eventName = eventData['eventName'] ?? 'No title';
              String venue = eventData['venue'] ?? 'Unknown';

              // Handle Timestamp fields
              Timestamp timestampDate = eventData['date'] ?? Timestamp.now();
              Timestamp timestampStartTime =
                  eventData['startTime'] ?? Timestamp.now();
              Timestamp timestampEndTime =
                  eventData['endTime'] ?? Timestamp.now();

              // Convert Timestamp to DateTime
              DateTime date = timestampDate.toDate();
              DateTime startTime = timestampStartTime.toDate();
              DateTime endTime = timestampEndTime.toDate();

              // Format the date and time
              String formattedDate = DateFormat('dd-MM-yyyy').format(date);
              String formattedStartTime = DateFormat('HH:mm').format(startTime);
              String formattedEndTime = DateFormat('HH:mm').format(endTime);

              String timeRange = '$formattedStartTime - $formattedEndTime';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventTemplatePage(
                        title: eventName,
                        isSuperAdmin: _isAdmin,
                        eventRef: eventRef,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/bg_img.jpg',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.red,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      eventName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    ' $formattedDate',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    ' $timeRange',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    ' $venue',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        );
      },
    );
  }
}
