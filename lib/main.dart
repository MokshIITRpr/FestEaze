import 'package:flutter/material.dart';
import 'Messages/messages.dart';
import 'Pages/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent[400],
          title: Text(
            welcomeMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          centerTitle: true,
          // TODO(Swayam) : add a leading image or icon here maybe
        ),
        body: LoginPage(),
      ),
    );
  }
}
