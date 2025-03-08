import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fest_app/data.dart';
import 'dart:math';

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
      body: Stack(
        children: [
          // Background Sponsors - Fill the entire screen with repeated images
          Positioned.fill(
            child: Opacity(
              opacity: 0.4, // Increased visibility
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(), // Keep it static
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Controls how many images in a row
                ),
                itemCount: 30, // Repeats sponsors multiple times
                itemBuilder: (context, index) {
                  return Image.asset(
                    sponsorImages[
                        index % sponsorImages.length], // Cycle through images
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),

          // Centered Content
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color:
                    const Color.fromARGB(255, 84, 91, 216).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
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
                  Text(
                    "Your QR Code",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  isLoading
                      ? CircularProgressIndicator()
                      : qrData != null
                          ? QrImageView(
                              data: qrData!,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            )
                          : Text("No QR info"),
                  SizedBox(height: 10),
                  if (userName != null)
                    Text(
                      "Hello, $userName!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 10),
                  Text(
                    "Scan this QR code to get user details.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Logout",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
