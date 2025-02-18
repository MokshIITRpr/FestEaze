import 'dart:async';
import 'package:fest_app/messages/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupVerificationPage extends StatefulWidget {
  const SignupVerificationPage({super.key});

  @override
  _SignupVerificationPageState createState() => _SignupVerificationPageState();
}

class _SignupVerificationPageState extends State<SignupVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Timer timer;
  bool isResending = false;
  bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkEmailVerification();
    });
    Future.delayed(const Duration(minutes: 5), () {
      _deleteUnverifiedUser();
    });
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Verification email sent! Check your inbox.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending email: $e")),
      );
    }
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      timer.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email has been verified Successfully!")),
      );
      Navigator.pushReplacementNamed(context, '/homeScreen');
    }
  }

  Future<void> _deleteUnverifiedUser() async {
    User? user = _auth.currentUser;
    await user?.reload();
    if (user != null && !user.emailVerified) {
      await user.delete();
      setState(() {
        isDeleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not verified. Account deleted.")),
      );
      Navigator.pushReplacementNamed(context, '/homeScreen');
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (isResending || isDeleted) return;
    setState(() => isResending = true);
    await _sendVerificationEmail();
    setState(() => isResending = false);
  }

  @override
  void dispose() {
    timer.cancel();
    _deleteUnverifiedUser();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              isDeleted ? verificationFailedMessage : verifyingEmailMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            isDeleted
                ? InkWell(
                    onTap: () => Navigator.pushReplacementNamed(
                        context, '/signupScreen'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Go Back to Signup",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 30),
                      const Text("Didn't receive the email?",
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _resendVerificationEmail,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isResending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  "Resend Verification Email",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
