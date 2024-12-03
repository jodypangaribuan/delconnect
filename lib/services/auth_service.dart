import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await saveAuthStatus(false);
    } catch (e) {
      rethrow;
    }
  }
}
