import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Pages/Login/loginMainScreen.dart';
import 'Pages/Signup/SignupPage.dart';
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
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.idTokenChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.data != null) {
              return const HomeMainScreen();
            }
            return const SignupPage();
          }),
      // home:LoginMainScreen(),
      routes: {
        '/loginScreen': (context) => LoginMainScreen(),
        '/signupPage': (context) => SignupPage(),
        '/homeScreen': (context) => HomeMainScreen(),
      },
    );
  }
}
