import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String AUTH_STATUS_KEY = 'auth_status';

  Future<bool> isLoggedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await saveAuthStatus(true);
      return true;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AUTH_STATUS_KEY) ?? false;
  }

  Future<void> saveAuthStatus(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AUTH_STATUS_KEY, isLoggedIn);
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      // Attempt to sign in
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last seen
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user?.uid)
          .update({
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
      });

      await saveAuthStatus(true);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Email atau password salah',
        );
      }
      rethrow;
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await saveAuthStatus(false);
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
