import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:proyecto/componentes/button1.dart';
import 'package:proyecto/componentes/textfield.dart';
import 'package:proyecto/pantallas/password_reset_screen.dart';
import 'package:proyecto/services/auth_service.dart';

import '../componentes/interfaz_msg.dart';
import '../componentes/contenedor_cuadrado.dart';
import 'home_screen.dart';

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
      builder: (context) => Center(
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
                "Cargando...",
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

  //fb
  facebookLogin() async {
    showLoading();
    try {
      final fb = FacebookAuth.instance;

      final res = await fb.login();
      switch (res.status) {
        case LoginStatus.success:
          print('Success');

          final accessToken = res.accessToken;

          final userData = await FacebookAuth.instance.getUserData();

          final profilePicture = userData['picture']['data']['url'];

          final OAuthCredential credential = FacebookAuthProvider.credential(
            accessToken!.tokenString,
          );

          final result = await FirebaseAuth.instance.signInWithCredential(
            credential,
          );

          await result.user?.updatePhotoURL(profilePicture);

          await FirebaseAuth.instance.currentUser?.reload();

          print("foto de perfil desde fb $profilePicture");
          print("foto de perfil desde firebase ${result.user?.photoURL}");

          //user credential to sign in with firebase

          print('${result.user?.email} is logged in with Facebook');

          showMsg('Iniciaste sesión con Facebook exitosamente.', Colors.green);

          break;

        case LoginStatus.cancelled:
          print('Cancelled');
          exitCircle();
          showMsg('Inicio de sesión con Facebook cancelado.', Colors.orange);
          break;
        case LoginStatus.failed:
          print('Failed');
          exitCircle();
          showMsg(
            'Error al iniciar sesión con Facebook, inténtalo de nuevo más tarde.',
            Colors.red,
          );
          break;
        case LoginStatus.operationInProgress:
          exitCircle();
          break;
      }
    } catch (e) {
      print(e);
      exitCircle();
      showMsg('Ocurrió un error al iniciar sesión con Facebook.', Colors.red);
    }
  }

  //google
  googleLogin() async {
    showLoading();

    try {
      // sign in process

      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        exitCircle();
        showMsg('Inicio de sesión cancelado.', Colors.orange);
        return;
      }

      //auth details

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      //create a new credential

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      //SIGN IN
      await FirebaseAuth.instance.signInWithCredential(credential);

      //no se por que? pero se ocupan dos exits para popear el circulo...
    } catch (e) {
      exitCircle();
      showMsg('Error al iniciar sesión con Google.', Colors.red);
      return;
    }
    exitCircle();
    showMsg('Inicio de sesión con Google exitoso.', Colors.green);
  }

  Future<void> handleLogin() async {
    FirebaseAuth.instance.signOut();

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

      if (userCredential.user != null &&
          userCredential.user?.emailVerified == false) {
        //verificacion email
        print("usuario sin Verificacion email");
        await FirebaseAuth.instance.signOut();
        exitCircle();
        showMsg('Verifica tu correo antes de iniciar sesion', Colors.orange);
        return;
      } else {
        exitCircle();
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
                const SizedBox(height: 35),

                // logo
                Image.asset(
                  'assets/img/logo.png',
                  height: 180,
                ),
                const SizedBox(height: 35),

                // bienvenido de vuelta
                Text(
                  'Bienvenido a Smart Vida',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                      color: Colors.grey[700]
                  ),
                ),

                const SizedBox(height: 40),

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


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordResetScreen(onTap: () {  },),
                            ),
                          );
                        },
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: const TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 25),

                //login button
                Button1(onTap: handleLogin, text: 'Iniciar sesión', fontSize: 16,),

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
                      onTap: () => googleLogin(),
                      imagePath: 'assets/img/google.png',
                    ),

                    const SizedBox(width: 10),

                    //boton facebook
                    SquareTile(
                      imagePath: 'assets/img/facebook.webp',
                      onTap: () => facebookLogin(),
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
