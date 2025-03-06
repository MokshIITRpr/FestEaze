import 'package:fest_app/pages/Homepages/aboutUs.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/exploreEvents.dart';
import 'package:fest_app/pages/Homepages/map.dart';
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

    final List<Widget> _pages = [
      AboutUs(),
      ExploreEvents(),
      ClgMap(),
      user != null ? QRScreen() : LoginMainScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: IndexedStack(
          key: ValueKey<int>(_selectedIndex),
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: const Color.fromARGB(255, 84, 91, 216), // Deep blue
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            items: [
              _buildNavItem(Icons.info, 'About'),
              _buildNavItem(Icons.event, 'Events'),
              _buildNavItem(Icons.map, 'Map'),
              _buildNavItem(
                user != null ? Icons.account_circle : Icons.login,
                user != null ? 'Profile' : 'Login',
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 26),
      activeIcon: Icon(icon, size: 30, color: Colors.white),
      label: label,
    );
  }
}
