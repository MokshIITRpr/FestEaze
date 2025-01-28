import 'package:flutter/material.dart';
import 'Pages/Login/loginMainScreen.dart';
import 'Pages/Home/homeMainScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      home: Loginmainscreen(),
      routes: {
        '/homeScreen': (context) => Homemainscreen(),
      },
    );
  }
}
