import 'package:flutter/material.dart';
import '../../../messages/messages.dart';

class LoginTextWidget extends StatefulWidget {
  const LoginTextWidget({super.key});
  @override
  LoginTextWidgetState createState() => LoginTextWidgetState();
}

class LoginTextWidgetState extends State<LoginTextWidget> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  String get username => usernameController.text;
  String get password => passwordController.text;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color.fromRGBO(143, 148, 251, 1)))),
          child: TextField(
            controller: usernameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: emailMessage,
              hintText: "Enter your email",
              hintStyle: TextStyle(color: Colors.grey[800]),
              labelStyle: TextStyle(color: Colors.black),
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
              hintStyle: TextStyle(color: Colors.grey[800]),
              labelStyle: TextStyle(color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
