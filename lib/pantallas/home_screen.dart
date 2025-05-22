import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto/pantallas/control_frontal_screen.dart';
import '../services/utils.dart';
import 'edit_profile_screen.dart';
import 'leds_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> logOut(BuildContext context) async {
    showLoading();
    await FirebaseAuth.instance.signOut();
    exitCircle();
  }

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/gif/loadingDaftPunk.gif',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Guardando cambios...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: GoogleFonts.orbitron().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void exitCircle() {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Smart Vida',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: GoogleFonts.orbitron().fontFamily),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () async {
                showLoading();
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );

                await FirebaseAuth.instance.currentUser?.reload();
                setState(() {});
                exitCircle();
              },

              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  user?.photoURL ??
                      'https://www.gravatar.com/avatar/placeholder.png?d=mp',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.displayName ?? user?.email}! 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BluetoothScreen()),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/gif/controladorLateral.gif',
                      width: 76,
                      height: 76,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Controlador Lateral",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ControlFrontalScreen()),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/gif/controladorFrontal.gif',
                      width: 76,
                      height: 76,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Controlador Frontal",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
