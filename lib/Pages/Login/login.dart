import 'package:flutter/material.dart';
import '/Messages/messages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _username = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Username
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: usernameMessage,
              hintText: 'Enter your username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),

          // Password
          TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: passwordMessage,
              hintText: 'Enter your password',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                    _username = usernameController.text;
                    _password = passwordController.text;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 30),

          // Login Button
          ElevatedButton(
            onPressed: () {
              _username = usernameController.text;
              _password = passwordController.text;

              // null check
              if (_username.isEmpty || _password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields')),
                );
              } else {
                Navigator.pushNamed(context, '/homeScreen');
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(loginMessage),
          ),
        ],
      ),
    );
  }
}
