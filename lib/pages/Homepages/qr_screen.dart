import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fest_app/data.dart';
import 'dart:math';
import 'package:flutter/widgets.dart'; // For WidgetStateProperty

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

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          qrData = userDoc['qrCodeData'];
          userName = userDoc['username'];
          isLoading = false;
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                child: Container(
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
                                if (states.contains(MaterialState.pressed)) {
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
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
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
}
