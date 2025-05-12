import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:proyecto/componentes/button1.dart';
import 'package:proyecto/componentes/textfield.dart';

import '../componentes/interfaz_msg.dart';
import '../componentes/contenedor_cuadrado.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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

  Future<void> handleRegister() async {
    try {
      //confirmar contrasenha

      if (passwordController.text != confirmPasswordController.text) {
        showMsg('Las contraseñas no coinciden.', Colors.red);
        return;
      }

      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      FirebaseAuth.instance.signOut();

      showMsg(
        'Registro exitoso. Para acceder a tu cuenta, revisa tu correo electronico y verifica tu cuenta.',
        Colors.orange,
      );
    } on FirebaseAuthException catch (e) {
      final message = getMailAuthErrorMessage(e.code);
      showMsg(message, Colors.red);
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
                  'Regístrate ahora!',
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

                const SizedBox(height: 25),

                //confirm password
                TxtField(
                  controller: confirmPasswordController,
                  hintText: 'Confirmar contraseña',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                //login button
                Button1(onTap: handleRegister, text: 'Registrarse'),

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
                      '¿Ya tienes una cuenta?',
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
                          'Inicia sesión',
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
