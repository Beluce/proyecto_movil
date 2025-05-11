import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTxtController = TextEditingController();
  final passwordTxtController = TextEditingController();

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

  Future<void> handleLogin() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTxtController.text.trim(),
        password: passwordTxtController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        showMsg('Por favor, verifica tu correo antes de iniciar sesión.', Colors.red);
        return;
      }

      showMsg('Inicio de sesión exitoso.', Colors.green);
    } on FirebaseAuthException catch (e) {
      final message = getMailAuthErrorMessage(e.code);
      showMsg(message, Colors.red);
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
        return 'Credenciales incorrectas. Si creaste tu cuenta con Google, usa esa opción.';
      default:
        return 'No se ha podido iniciar sesión, inténtalo nuevamente.';
    }
  }

  Future<void> handleRegister() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTxtController.text.trim(),
        password: passwordTxtController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      showMsg('Registro exitoso. Revisa tu correo para verificar la cuenta.', Colors.green);
    } on FirebaseAuthException catch (e) {
      final message = getMailAuthErrorMessage(e.code);
      showMsg(message, Colors.red);
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
      showMsg('Error con Google. Verifica tu conexión y configuración del proyecto.', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailTxtController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordTxtController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  AuthButton(label: 'Iniciar sesión', onPressed: handleLogin),
                  const SizedBox(height: 10),
                  AuthButton(label: 'Registrarse', onPressed: handleRegister),
                  const Divider(height: 30),
                  AuthButton(
                    label: 'Iniciar con Google',
                    icon: Icons.g_mobiledata,
                    onPressed: handleGoogleLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: icon == null
          ? ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label),
      )
          : ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
