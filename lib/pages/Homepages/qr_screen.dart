import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String? qrData;
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQRData();
  }

  Future<void> _loadQRData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Redirect to login if not logged in
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          qrData = userDoc['qrCodeData'];
          userName = userDoc['name']; // Ensure Firestore contains this field
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
      await FirebaseAuth.instance.signOut();
      print("User signed out successfully");

      // Navigate to login page and remove all previous routes
      Navigator.pushReplacementNamed(context, '/homeScreen');
    } catch (e) {
      print("Logout failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed. Please try again!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your QR Code"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : qrData == null
                ? Text("No QR Code found!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QrImageView(
                        data: qrData!,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                      SizedBox(height: 20),
                      if (userName != null)
                        Text(
                          "Hello, $userName!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 20),
                      Text(
                        "Scan this QR code to get user details.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _logout, // ✅ Logout function
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
