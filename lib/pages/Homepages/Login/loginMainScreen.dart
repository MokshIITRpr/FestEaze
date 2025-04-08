import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../messages/messages.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fest_app/pages/Homepages/Login/loginTextWidget.dart';
import 'package:fest_app/snackbar.dart';

class LoginMainScreen extends StatefulWidget {
  const LoginMainScreen({super.key});
  @override
  _LoginMainScreenState createState() => _LoginMainScreenState();
}

class _LoginMainScreenState extends State<LoginMainScreen> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<LoginTextWidgetState> _loginKey =
      GlobalKey<LoginTextWidgetState>();

  String _username = "";
  String _password = "";

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loginUser() async {
    try {
      await _auth.signInWithEmailAndPassword(
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
                height: 300,
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
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/light-1.png'))),
                          )),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                          duration: Duration(milliseconds: 600),
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
                          duration: Duration(milliseconds: 750),
                          child: Icon(Icons.sports_basketball_rounded,
                              color: Colors.white, size: 60)),
                    ),
                    Positioned(
                      child: FadeInUp(
                          duration: Duration(milliseconds: 800),
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
                        duration: Duration(milliseconds: 900),
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
                          child: LoginTextWidget(key: _loginKey),
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    FadeInUp(
                        duration: Duration(milliseconds: 950),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgotPassword');
                            },
                            child: Text(
                              forgotPassword,
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 84, 91, 216)),
                            ))),
                    SizedBox(
                      height: 20,
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 84, 91, 216),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () async {
                            _username = _loginKey.currentState!.username;
                            _password = _loginKey.currentState!.password;

                            // null check
                            if (_username.isEmpty || _password.isEmpty) {
                              // Use custom snackbar instead
                              showCustomSnackBar(
                                context,
                                'Please fill in all fields',
                                backgroundColor: const Color.fromARGB(255, 84, 91, 216),
                                icon: Icons.info,
                              );
                            } else {
                              try {
                                await loginUser();
                                Navigator.pushReplacementNamed(
                                    context, '/homeScreen');
                              } on FirebaseAuthException catch (e) {
                                showCustomSnackBar(
                                  context,
                                  e.message ?? 'An error occurred',
                                  backgroundColor: Colors.red,
                                  icon: Icons.info,
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
                      duration: Duration(milliseconds: 1100),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signupPage');
                          },
                          child: Text(
                            signupHere,
                            style: TextStyle(
                              color:
                                  const Color.fromARGB(255, 84, 91, 216),
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
      ),
    );
  }
}
