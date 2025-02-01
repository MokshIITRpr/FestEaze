import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/Messages/messages.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  String _email = "";
  String _password = "";
  String _username = "";
  bool _obscurePassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> signupUser() async {
    try {
      final userCredentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      print(userCredentials);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent[400],
      ),
      body: Center(
        child: Container(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Username
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: usernameMessage,
                  hintText: 'Enter your usernamer',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: emailMessage,
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Password
              TextField(
                obscureText: _obscurePassword,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: passwordMessage,
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                        _username = usernameController.text;
                        _password = passwordController.text;
                        _email = emailController.text;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: () async {
                  _username = usernameController.text;
                  _email = emailController.text;
                  _password = passwordController.text;
                  if (_username.isEmpty ||
                      _password.isEmpty ||
                      _email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields')),
                    );
                  } else {
                    try {
                      await signupUser();
                      Navigator.pushNamed(context, '/loginScreen');
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message!)),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(signupMessage),
              ),
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/loginScreen');
                  },
                  child: Text(
                    'Already Have an Account?',
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
      ),
    );
  }
}
