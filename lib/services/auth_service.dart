import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String AUTH_STATUS_KEY = 'auth_status';

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // User is logged in through Firebase
      await saveAuthStatus(true);
      return true;
    }

    // Check local storage as fallback
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AUTH_STATUS_KEY) ?? false;
  }

  // Save auth status
  Future<void> saveAuthStatus(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AUTH_STATUS_KEY, isLoggedIn);
  }

  // Sign in method
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveAuthStatus(true);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await saveAuthStatus(false);
    } catch (e) {
      rethrow;
    }
  }
}
