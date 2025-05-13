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
    bool emailUser;
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              ((snapshot.data?.emailVerified == false) &&
                  (snapshot.data?.providerData.any(
                        (p) => p.providerId == 'facebook.com',
                  ) ==
                      false) &&
                  (snapshot.data?.providerData.any(
                        (p) => p.providerId == 'google.com',
                  ) ==
                      false))) {
            FirebaseAuth.instance.signOut();
            return LoginRegisterScreen();
          }
          if (snapshot.hasData &&
              ((snapshot.data?.emailVerified == true) ||
                  (snapshot.data?.providerData.any(
                        (p) => p.providerId == 'facebook.com',
                      ) ==
                      true) ||
                  (snapshot.data?.providerData.any(
                        (p) => p.providerId == 'google.com',
                      ) ==
                      true))) {
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
