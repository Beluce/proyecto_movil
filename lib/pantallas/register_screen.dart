import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:proyecto/componentes/button1.dart';
import 'package:proyecto/componentes/textfield.dart';
import 'package:proyecto/pantallas/login_register_screen.dart';
import 'package:proyecto/pantallas/login_screen.dart';

import '../componentes/interfaz_msg.dart';
import '../componentes/contenedor_cuadrado.dart';
import '../services/auth_service.dart';

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

      final res = await fb.login(permissions: ['email', 'public_profile']);
      switch (res.status) {
        case LoginStatus.success:
          print('Success');

          final AccessToken accessToken = res.accessToken!;

          final userData = await FacebookAuth.instance.getUserData();

          final OAuthCredential credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );

          final result = await FirebaseAuth.instance.signInWithCredential(
            credential,
          );

          final profilePicture = userData['picture']['data']['url'];
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

  Future<void> handleRegister() async {
    final FocusNode emptyFocusNode = FocusNode(); //desenfocar campos de texto al clickear en registrarse:)
    try {
      //confirmar contrasenha

      if (passwordController.text != confirmPasswordController.text) {
        showMsg('Las contraseñas no coinciden.', Colors.red);
        return;
      }

      showLoading();

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      //await FirebaseAuth.instance.signOut(); // si brickea, quitar pls

      exitCircle();

      showMsg(
        'Registro exitoso. Para acceder a tu cuenta, revisa tu correo electronico y verifica tu cuenta.',
        Colors.orange,
      );

      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      FocusScope.of(context).requestFocus(emptyFocusNode); //para limpiar el enfoque en los input text field

      //Navigator.pushNamed(context, '/login_screen');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => LoginScreen(onTap: widget.onTap),
        ),
      );



    } on FirebaseAuthException catch (e) {
      final message = getMailAuthErrorMessage(e.code);
      exitCircle();
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
                Image.asset(
                  'assets/img/logo.png',
                  height: 180,
                ),
                const SizedBox(height: 15),

                // bienvenido de vuelta
                Text(
                  'Regístrate ahora:',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
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

                //register button
                Button1(onTap: handleRegister, text: 'Registrarse', fontSize: 16),

                const SizedBox(height: 35),

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

                const SizedBox(height: 35),

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

                const SizedBox(height: 35),

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
                        Navigator.pushNamed(context, '/login_screen');
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
