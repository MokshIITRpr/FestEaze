import 'package:flutter/material.dart';
import './imageBuilder.dart';
import '/Messages/messages.dart';
import 'login.dart';

class Loginmainscreen extends StatelessWidget {
  const Loginmainscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 200,
              child: ImageBuilder(),
            ),
            LoginPage(),
          ],
        ),
      ),
    );
  }
}
