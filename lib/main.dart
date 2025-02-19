import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/Homepages/Login/loginMainScreen.dart';
import 'pages/Homepages/Signup/signupPage.dart';
import 'pages/Home/homeMainScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebaseOptions.dart';
import 'pages/Homepages/Signup/signupVerification.dart';

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
      home: StreamBuilder(
          stream: FirebaseAuth.instance.idTokenChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return const HomeMainScreen();
          }),
      routes: {
        '/loginScreen': (context) => LoginMainScreen(),
        '/signupPage': (context) => SignupPage(),
        '/homeScreen': (context) => HomeMainScreen(),
        '/verificationScreen': (context) => SignupVerificationPage(),
      },
    );
  }
}
