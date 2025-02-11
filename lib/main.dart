import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Pages/Login/loginMainScreen.dart';
import 'Pages/Signup/signupPage.dart';
import 'Pages/Home/homeMainScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Pages/Signup/signupVerification.dart';

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
            //raj ne hataya h home page p jaane k liye baad mai sahi kr lena
            // if (snapshot.data != null) {
            //   return const HomeMainScreen();
            // }
            return const HomeMainScreen();
          }),
      // home:LoginMainScreen(),
      routes: {
        '/loginScreen': (context) => LoginMainScreen(),
        '/signupPage': (context) => SignupPage(),
        '/homeScreen': (context) => HomeMainScreen(),
        '/verificationScreen': (context) => SignupVerificationPage(),
      },
    );
  }
}
