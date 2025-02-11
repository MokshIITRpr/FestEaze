import 'package:fest_app/Pages/Homepages/PastEvents/ad24.dart';
import 'package:fest_app/Pages/Homepages/PastEvents/ar24.dart';
import 'package:fest_app/Pages/Homepages/PastEvents/z24.dart';
import 'package:flutter/material.dart';

class PastEvents extends StatelessWidget {
  const PastEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Past Events', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adds padding to the sides
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedContainer(
              context: context,
              title: "Zeitgeist 2024",
              icon: Icons.workspaces_filled,
              color: Colors.deepOrangeAccent[200]!,
              navigateTo: Z24(),
            ),
            SizedBox(height: 15),
            _buildAnimatedContainer(
              context: context,
              title: "Advitiya 2024",
              icon: Icons.workspaces_filled,
              color: Colors.deepOrangeAccent[200]!,
              navigateTo: Ad24(),
            ),
            SizedBox(height: 15),
            _buildAnimatedContainer(
              context: context,
              title: "Aarohan 2024",
              icon: Icons.workspaces_filled,
              color: Colors.deepOrangeAccent[200]!,
              navigateTo: Ar24(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Widget navigateTo,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigateTo),
        );
      },
      splashColor: Colors.deepPurpleAccent, 
      borderRadius: BorderRadius.circular(15),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        height: 100,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
