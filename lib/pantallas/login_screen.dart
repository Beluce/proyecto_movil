import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:proyecto/componentes/button1.dart';
import 'package:proyecto/componentes/textfield.dart';

import '../componentes/interfaz_msg.dart';
import '../componentes/contenedor_cuadrado.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void exitCircle(){
    ScaffoldMessenger.of(context).clearSnackBars();
    Navigator.pop(context);
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

  Future<void> handleLogin() async {

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showMsg('Por favor ingresa tu correo y contraseña.', Colors.red);
      return;
    }
    showLoading();
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (userCredential.user != null && userCredential.user?.emailVerified == false) {
        //verificacion email
        FirebaseAuth.instance.signOut();
        exitCircle();
        showMsg('Verifica tu correo antes de iniciar sesion', Colors.orange);
        return;
      } else{
        exitCircle();
        showMsg('Inicio de sesión exitoso.', Colors.green);
      }

    } on FirebaseAuthException catch (e) {
      exitCircle();
      showMsg(getMailAuthErrorMessage(e.code), Colors.red);
    }
  }

  String getMailAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No se encontró una cuenta asociada con ese correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Vuelve a intentarlo más tarde.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado!';
      case 'weak-password':
        return 'La contraseña no cumple con los requerimentos establecidos.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida.';
      case 'invalid-credential':
        return 'La cuenta no ha sido encontrada.';
      default:
        return 'No se ha podido iniciar sesión, inténtalo nuevamente.';
    }
  }

  Future<void> handleGoogleLogin() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();
      if (user == null) {
        showMsg('Inicio de sesión cancelado por el usuario.', Colors.red);
        return;
      }

      final auth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      showMsg('Inicio de sesión con Google exitoso.', Colors.green);
    } catch (e) {
      showMsg(
        'Error con Google. Verifica tu conexión y configuración del proyecto.',
        Colors.red,
      );
    }
  }

  Future<void> handleFacebookLogin() async {
    try {
      final LoginResult result =
          await FacebookAuth.instance
              .login(); // email y perfil publico de facebook

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);

        showMsg('Inicio de sesión con Facebook exitoso.', Colors.green);
      } else if (result.status == LoginStatus.cancelled) {
        showMsg('Inicio de sesión con Facebook cancelado.', Colors.orange);
      } else {
        showMsg(
          'Error al iniciar sesión con Facebook: ${result.message}',
          Colors.red,
        );
      }
    } catch (e) {
      showMsg(
        'Ocurrió un error inesperado al iniciar sesión con Facebook.',
        Colors.red,
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                const Icon(Icons.lock, size: 100),
                const SizedBox(height: 50),

                // bienvenido de vuelta
                Text(
                  'Bienvenido a Smart Vida!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),

                const SizedBox(height: 25),

                //username textfield
                TxtField(
                  controller: emailController,
                  hintText: 'Correo electrónico',
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                //password textfield
                TxtField(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //login button
                Button1(onTap: handleLogin, text: 'Iniciar sesión'),

                const SizedBox(height: 50),

                //or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'O inicia sesion con:',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),

                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                //google + facebook btns
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //boton google
                    SquareTile(
                      imagePath: 'lib/img/google.png',
                      onTap: handleGoogleLogin,
                    ),

                    const SizedBox(width: 10),

                    //boton facebook
                    SquareTile(
                      imagePath: 'lib/img/facebook.webp',
                      onTap: handleFacebookLogin,
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes una cuenta?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),

                    const SizedBox(width: 4),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register_screen');
                      },
                      child: GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Regístrate ahora',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
