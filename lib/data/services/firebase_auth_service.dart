import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/auth_repository.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  // Inicializa Google Sign-In
  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId:
            '874246422550-ear06h74t4vdnrk07qk6qaef0erton5e.apps.googleusercontent.com',
      );
      isInitialize = true;
    }
  }

  // SIGN IN
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await initSignIn();

      // Login con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return null; // usuario canceló

      // Token de Google / Firebase
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: "idToken-null",
          message: "No se obtuvo idToken de Google",
        );
      }

      // Login en Firebase
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;
      if (user == null) return null;

      // Crear documento en Firestore si no existe
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Devuelve token de Firebase (JWT) + info del usuario
      final firebaseIdToken = await user.getIdToken(true);

      return {
        'googleIdToken': firebaseIdToken,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
      };
    } catch (e) {
      print('Error en signInWithGoogle: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error en cierre de sesión: $e');
      rethrow;
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
