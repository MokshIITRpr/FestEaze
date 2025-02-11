import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './imageBuilder.dart';
import '/Messages/messages.dart';
import 'package:animate_do/animate_do.dart';

class LoginMainScreen extends StatefulWidget {
  const LoginMainScreen({super.key});
  @override
  _LoginMainScreenState createState() => _LoginMainScreenState();
}

class _LoginMainScreenState extends State<LoginMainScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _obscurePassword = true;
  String _username = "";
  String _password = "";

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    try {
      final userCredentials = await _auth.signInWithEmailAndPassword(
          email: _username, password: _password);
      // print(userCredentials);
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
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/background.png'),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeInUp(
                            duration: Duration(seconds: 1),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/light-1.png'))),
                            )),
                      ),
                      Positioned(
                        left: 120,
                        width: 80,
                        height: 470,
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1600),
                            child: Icon(
                              Icons.computer_rounded,
                              color: Colors.white,
                              size: 180,
                            )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1200),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/light-2.png'))),
                            )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1300),
                            child: Icon(Icons.sports_basketball_rounded,
                                color: Colors.white, size: 60)),
                      ),
                      Positioned(
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1600),
                            child: Container(
                              margin: EdgeInsets.only(top: 50),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeInUp(
                          duration: Duration(milliseconds: 1800),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Color.fromRGBO(143, 148, 251, 1)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(143, 148, 251, .2),
                                      blurRadius: 20.0,
                                      offset: Offset(0, 10))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color.fromRGBO(
                                                  143, 148, 251, 1)))),
                                  child: TextField(
                                    controller: usernameController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelText: emailMessage,
                                      hintText: "Enter your email",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[800]),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextField(
                                    obscureText: _obscurePassword,
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter your password",
                                      labelText: passwordMessage,
                                      hintStyle:
                                          TextStyle(color: Colors.grey[800]),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                            _username = usernameController.text;
                                            _password = passwordController.text;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeInUp(
                          duration: Duration(milliseconds: 1900),
                          child: Text(
                            forgotPassword,
                            style: TextStyle(
                                color: Color.fromRGBO(143, 148, 251, 1)),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      FadeInUp(
                        duration: Duration(milliseconds: 2000),
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () async {
                              _username = usernameController.text;
                              _password = passwordController.text;

                              // null check
                              if (_username.isEmpty || _password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Please fill in all fields')),
                                );
                              } else {
                                try {
                                  await loginUser();
                                  Navigator.pushNamed(context, '/homeScreen');
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.message!)),
                                  );
                                }
                              }
                            },
                            child: Text(
                              loginMessage,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      FadeInUp(
                        duration: Duration(milliseconds: 2000),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signupPage');
                            },
                            child: Text(
                              signupHere,
                              style: TextStyle(
                                color: Color.fromRGBO(143, 148, 251, 1),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            )),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
