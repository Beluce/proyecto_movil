import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:proyecto/componentes/button1.dart';
import 'package:proyecto/componentes/textfield.dart';
import 'package:proyecto/services/auth_service.dart';

import '../componentes/interfaz_msg.dart';
import '../componentes/contenedor_cuadrado.dart';
import 'home_screen.dart';

class PasswordResetScreen extends StatefulWidget {
  final Function()? onTap;
  const PasswordResetScreen({super.key, required this.onTap});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  passwordReset() async {
    showLoading();
    await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim());
    exitCircle();
    showMsg('Correo de recuperación de contraseña enviado.', Colors.green);
  }

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void exitCircle() {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    Image.asset(
                      'assets/img/logo.png',
                      height: 180,
                    ),
                    const SizedBox(height: 35),

                    Text(
                      'Ingresa tu correo para recuperar tu contraseña:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),

                    const SizedBox(height: 40),

                    TxtField(
                      controller: emailController,
                      hintText: 'Correo electrónico',
                      obscureText: false,
                    ),

                    const SizedBox(height: 25),

                    Button1(
                      onTap: passwordReset,
                      text: 'Enviar correo de recuperación',
                      fontSize: 16,
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}