import 'package:fest_app/pages/Homepages/aboutUs.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/exploreEvents.dart';
import 'package:fest_app/pages/Homepages/map.dart';
import 'package:fest_app/pages/Homepages/pastEvent.dart';
import 'package:fest_app/pages/Homepages/Login/loginMainScreen.dart';
import 'package:fest_app/pages/Homepages/qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    //print(user != null ? user.uid : "NO USER");

    // If user is logged in, show QR screen, otherwise show Login screen
    final List<Widget> _pages = [
      AboutUs(),
      ExploreEvents(),
      PastEvents(),
      Clgmap(),
      user != null ? QRScreen() : LoginMainScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: IndexedStack(
          key: ValueKey<int>(_selectedIndex),
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.deepPurple[700],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: [
          _buildNavItem(Icons.info, 'About Us'),
          _buildNavItem(Icons.event, 'Explore Events'),
          _buildNavItem(Icons.event, 'Past Events'),
          _buildNavItem(Icons.map, 'Map'),
          _buildNavItem(user != null ? Icons.account_circle : Icons.login,
              user != null ? 'Profile' : 'Login'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 28),
      label: label,
    );
  }
}
