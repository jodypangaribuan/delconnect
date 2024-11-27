import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import '../routes/app_routes.dart';
import '../utils/logger.dart';
import '../widgets/shadcn_button.dart';
import '../constants/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      AppLogger.log('Starting Google Sign In process');

      try {
        await FirebaseAuth.instance.signOut();
        AppLogger.log('Firebase Sign Out successful');
      } catch (e) {
        AppLogger.error('Firebase Sign Out failed', e);
      }

      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.signOut();
        AppLogger.log('Google Sign Out successful');
      } catch (e) {
        AppLogger.error('Google Sign Out failed', e);
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.log('Google Sign In cancelled by user');
        return;
      }
      AppLogger.log('Google Sign In successful', googleUser.email);

      if (!mounted) {
        AppLogger.log('Widget unmounted after Google Sign In');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      AppLogger.log('Got Google Auth tokens');

      if (!mounted) return;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential)
          .timeout(const Duration(seconds: 30));

      AppLogger.log('Firebase Sign In successful', userCredential.user?.email);

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } on FirebaseAuthException catch (e, stack) {
      AppLogger.error('Firebase Auth error', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_getErrorMessage(e.code)),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e, stack) {
      AppLogger.error('Sign In error', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign in error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Invalid password';
      case 'invalid-credential':
        return 'Invalid credentials';
      default:
        return 'Sign in failed: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Remove focus from any text field when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        body: LayoutBuilder(
          builder: (context, constraints) => Container(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.apartment_rounded,
                                size: 50, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Selamat Datang',
                        style: AppTheme.textStyleHeading.copyWith(
                          color:
                              isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Masuk untuk melanjutkan ke DelConnect',
                        style: AppTheme.textStyleSubheading.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'nama@student.del.ac.id',
                          filled: true,
                          fillColor: isDark ? AppTheme.darkInput : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : Colors.grey[700],
                          ),
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : const Color(0xFF64748B),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!value.endsWith('@student.del.ac.id')) {
                            return 'Gunakan email student.del.ac.id';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          hintText: 'Masukkan kata sandi',
                          filled: true,
                          fillColor: isDark ? AppTheme.darkInput : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : Colors.grey[700],
                            fontFamily: 'Inter',
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : Colors.grey[700],
                          ),
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : const Color(0xFF64748B),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : const Color(0xFF64748B),
                            size: 20,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.darkText : Colors.grey[700],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ShadcnButton(
                        onPressed: _login,
                        isLoading: _isLoading,
                        child: const Text('Masuk'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'atau',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ShadcnButton(
                        onPressed: _signInWithGoogle,
                        isPrimary: false,
                        isLoading: _isLoading,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              height: 18,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata_rounded,
                                      size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text('Masuk dengan Google'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum memiliki akun? ',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/register'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
