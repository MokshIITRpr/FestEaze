import 'package:fest_app/pages/Homepages/ForgotPass/forgot_pass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/Homepages/Login/loginMainScreen.dart';
import 'pages/Homepages/Signup/signupPage.dart';
import 'pages/Home/homeMainScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebaseOptions.dart';
import 'pages/Homepages/Signup/signupVerification.dart';
import 'package:fest_app/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While checking the authentication state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (snapshot.hasData) {
            UserData().clearCache();
            return HomeMainScreen();
          } else {
            return HomeMainScreen();
          }
        },
      ),
      routes: {
        '/loginScreen': (context) => LoginMainScreen(),
        '/signupPage': (context) => SignupPage(),
        '/forgotPassword': (context) => ForgotPass(),
        '/homeScreen': (context) => HomeMainScreen(),
        '/verificationScreen': (context) => SignupVerificationPage(),
      },
    );
  }
}
