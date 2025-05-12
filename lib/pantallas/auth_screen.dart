import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_register_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData && FirebaseAuth.instance.currentUser?.emailVerified == true) {
              //user logged in:
              return HomeScreen();
            }

            //user not logged in:
            else {
              return LoginRegisterScreen();
          }
        }
      ),
    );
  }
}
