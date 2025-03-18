import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../messages/messages.dart';
import 'package:animate_do/animate_do.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = "";
  String _email = "";
  String _password = "";
  bool _obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Signup user along with auth and QR generation.
  Future<void> signupUser() async {
    try {
      // OTP-based signup
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // User and QR details
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': _name,
          'email': _email,
          // QR stores user UID
          'qrCodeData': user.uid,
          // auth
          'admin': false,
          'fest-head': "None",
          'event-head': "None",
        });
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: FadeInUp(
                      duration: Duration(milliseconds: 800),
                      child: Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            "Signup",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 900),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: const Color.fromARGB(255, 84, 91, 216)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          // Name Field
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: const Color.fromARGB(255, 84, 91, 216)),
                              ),
                            ),
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: usernameMessage,
                                hintText: "Enter your username",
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          // Email Field
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Color.fromRGBO(143, 148, 251, 1)),
                              ),
                            ),
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: emailMessage,
                                hintText: "Enter your email",
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          // Password Field
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              obscureText: _obscurePassword,
                              controller: passwordController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter your password",
                                labelText: passwordMessage,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                labelStyle: TextStyle(color: Colors.black),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Signup Button
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 84, 91, 216),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          _name = nameController.text.trim();
                          _email = emailController.text.trim();
                          _password = passwordController.text.trim();

                          if (_name.isEmpty ||
                              _email.isEmpty ||
                              _password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Please fill in all fields')),
                            );
                          } else {
                            try {
                              await signupUser();
                              Navigator.pushReplacementNamed(
                                  context, '/verificationScreen');
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message!)),
                              );
                            }
                          }
                        },
                        child: Text(
                          signupMessage,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Already have an account? Login
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        haveAnAccountMessage,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 84, 91, 216),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
