import 'package:fest_app/pages/Homepages/aboutUs.dart';
import 'package:fest_app/pages/Homepages/ExploreEvents/exploreEvents.dart';
import 'package:fest_app/pages/Homepages/map.dart';
import 'package:fest_app/pages/Homepages/pastEvent.dart';
import 'package:fest_app/pages/Homepages/Login/loginMainScreen.dart';
import 'package:flutter/material.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AboutUs(),
    ExploreEvents(),
    PastEvents(),
    Clgmap(),
    LoginMainScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> navItems = [
      _buildNavItem(Icons.info, 'About Us'),
      _buildNavItem(Icons.event, 'Explore Events'),
      _buildNavItem(Icons.event, 'Past Events'),
      _buildNavItem(Icons.map, 'Map'),
      _buildNavItem(Icons.login, 'Login'),
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
        onTap: _onItemTapped,
        backgroundColor: Colors.deepPurple[700],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: navItems,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: MouseRegion(
        onEnter: (_) => setState(() {}),
        onExit: (_) => setState(() {}),
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          splashColor: Colors.purpleAccent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _selectedIndex ==
                      _pages.indexWhere((page) => label == page.toStringShort())
                  ? Colors.deepPurple[400]
                  : Colors.transparent,
            ),
            child: Icon(icon, size: 28),
          ),
        ),
      ),
      label: label,
    );
  }
}
