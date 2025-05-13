import 'package:flutter/material.dart';
import 'package:proyecto/pantallas/register_screen.dart';
import 'login_screen.dart';

class LoginRegisterScreen extends StatefulWidget {
  final bool showLoginScreen;
  const LoginRegisterScreen({super.key, this.showLoginScreen = true});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  // login screen first
  //bool showLoginScreen = true;

  @override
  void initState() { // inicializar el estado para mostrar el login screen (si no se inicializa, dara un error)
    super.initState();
    showLoginScreen = widget.showLoginScreen;
  }

  late bool showLoginScreen;

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
