import 'package:flutter/material.dart';
import 'package:proyecto/pantallas/register_screen.dart';
import 'login_screen.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  // login screen first
  bool showLoginScreen = true;

  // toggle login N register
  void toggleScreen() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen) {
      return LoginScreen(onTap: toggleScreen);
    } else {
      return RegisterScreen(onTap: toggleScreen);
    }
  }
}
