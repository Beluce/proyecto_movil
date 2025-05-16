import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../pantallas/login_screen.dart';

class AuthService {

  final fb = FacebookAuth.instance;

  facebookLogin() async {
    try {
      final res = await fb.login(permissions: ['email', 'public_profile']);

      switch (res.status) {
        case LoginStatus.success:
          print('Success');

          final AccessToken accessToken = res.accessToken!;

          final OAuthCredential credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );

          //user credential to sign in with firebase

          final result = await FirebaseAuth.instance.signInWithCredential(credential);

          print('${result.user?.email} is logged in with Facebook');

          break;
        case LoginStatus.cancelled:
          print('Cancelled');
          break;
        case LoginStatus.failed:
          print('Failed');
          break;
        case LoginStatus.operationInProgress:
          print('Operation in progress');
          break;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  //google
  googleLogin() async {
    // sign in process

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //auth details

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    //create a new credential

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    //SIGN IN

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
