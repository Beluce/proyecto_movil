import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/pantallas/login_screen.dart';
import 'home_screen.dart';
import 'login_register_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool emailUser;
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = FirebaseAuth.instance.currentUser?.providerData;

          if (user != null) {
            for (final info in user!) {
              if (info.providerId != 'password') {
                emailUser = true;
              }
            }
          }

          if (snapshot.hasData && ((FirebaseAuth.instance.currentUser?.emailVerified == true) /* || (FirebaseAuth.instance.currentUser?.) */ )) {
            //user logged in:
            return HomeScreen();
          }
          //user not logged in:
          else {
            return LoginRegisterScreen();
          }
        },
      ),
    );
  }
}
