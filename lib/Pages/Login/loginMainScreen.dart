import 'package:flutter/material.dart';
import './imageBuilder.dart';
import '/Messages/messages.dart';
import 'loginPage.dart';

class LoginMainScreen extends StatefulWidget {
  const LoginMainScreen({super.key});
  @override
  _LoginMainScreenState createState() => _LoginMainScreenState();
}

class _LoginMainScreenState extends State<LoginMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
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
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 200,
              child: ImageBuilder(),
            ),
            LoginPage(),
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signupPage');
                },
                child: Text(
                  'Signup Here',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
