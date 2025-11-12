import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  AuthServices() {
    // !kIsWeb = only for android or IOS, not Web
    if (!kIsWeb) {
      FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
        forceRecaptchaFlow: false
      );
    }
  }

  // get current user
  User? get currentUser => _auth.currentUser;

  // auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    } catch (e) {
      // untuk membalikkan kembali
      rethrow;
    }
  }

  // register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
        );
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'operation-not-allowed') {
          throw 'email/password sign up is not enabled. please contact support';
        }
      }
      rethrow;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}