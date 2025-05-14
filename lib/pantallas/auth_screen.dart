import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/pantallas/login_screen.dart';
import 'home_screen.dart';
import 'login_register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user == null) {
            return LoginRegisterScreen();
          }

          final isEmailVerified = user.emailVerified;
          final hasFacebook = user.providerData.any((p) =>
          p.providerId == 'facebook.com');
          final hasGoogle = user.providerData.any((p) =>
          p.providerId == 'google.com');

          // Si el usuario se registró por email, debe verificar su email.
          if (user.providerData.any((p) => p.providerId == 'password') &&
              !isEmailVerified) {
            FirebaseAuth.instance.signOut();
            return LoginRegisterScreen();
          }

          // Si llegó aquí, está logueado correctamente:
          return HomeScreen();
        },
      ),
    );
  }
}