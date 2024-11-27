import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../routes/app_routes.dart';
import '../utils/logger.dart';
import '../widgets/shadcn_button.dart';
import '../constants/app_theme.dart'; // Add this import

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        AppLogger.log('Starting email/password registration');

        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        AppLogger.log(
            'User registered successfully', userCredential.user?.email);

        await userCredential.user?.updateDisplayName(
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}');
        AppLogger.log('Display name updated');

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } on FirebaseAuthException catch (e, stack) {
        AppLogger.error('Firebase registration failed', e, stack);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getErrorMessage(e.code)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e, stack) {
        AppLogger.error('Registration failed', e, stack);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
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

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Registration failed: $code';
    }
  }

  Future<void> _signUpWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      AppLogger.log('Starting Google Sign Up process');

      // Sign out from Firebase first
      try {
        await FirebaseAuth.instance.signOut();
        AppLogger.log('Firebase Sign Out successful');
      } catch (e) {
        AppLogger.log('Firebase Sign Out failed', e);
      }

      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.signOut();
        AppLogger.log('Google Sign Out successful');
      } catch (e) {
        AppLogger.log('Google Sign Out failed', e);
      }

      // Attempt Google Sign In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      AppLogger.log('Google Sign In attempt completed',
          googleUser == null ? 'User cancelled' : 'User selected');

      if (!mounted) {
        AppLogger.log('Widget not mounted after Google Sign In');
        return;
      }

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get Google Auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      AppLogger.log('Got Google Auth tokens');

      if (!mounted) return;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Firebase sign in timed out');
        },
      );

      AppLogger.log('Firebase Sign In completed',
          userCredential.user?.email ?? 'No email');

      if (!mounted) return;

      if (userCredential.user != null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e, stack) {
      AppLogger.log('Sign Up error occurred', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
                      Text(
                        'Gabung DelConnect, Yuk!',
                        style: AppTheme.textStyleHeading.copyWith(
                          color:
                              isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buat akunmu dan mulai terhubung dengan teman-teman kampus.',
                        style: AppTheme.textStyleSubheading.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller:
                                  _firstNameController, // Add this controller to class
                              decoration: InputDecoration(
                                labelText: 'Nama Depan',
                                hintText: 'Jody',
                                filled: true,
                                fillColor:
                                    isDark ? AppTheme.darkInput : Colors.white,
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
                                    width: 1,
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
                                  Icons.person_outline,
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
                                color: isDark
                                    ? AppTheme.darkText
                                    : Colors.grey[700],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama depan wajib diisi';
                                }
                                if (value.length < 2) {
                                  return 'Minimal 2 karakter';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller:
                                  _lastNameController, // Add this controller to class
                              decoration: InputDecoration(
                                labelText: 'Nama Belakang',
                                hintText: 'Pangaribuan',
                                filled: true,
                                fillColor:
                                    isDark ? AppTheme.darkInput : Colors.white,
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
                                    width: 1,
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
                                  Icons.person_outline,
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
                                color: isDark
                                    ? AppTheme.darkText
                                    : Colors.grey[700],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama belakang wajib diisi';
                                }
                                if (value.length < 2) {
                                  return 'Minimal 2 karakter';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'emailkamu@student.del.ac.id',
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
                              width: 1,
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
                            Icons.email_outlined,
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
                          hintText: 'Min. 8 karakter',
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
                              width: 1,
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
                          if (value.length < 8) {
                            return 'Minimal 8 karakter';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Harus mengandung huruf besar';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Harus mengandung angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ShadcnButton(
                        onPressed: _register,
                        isLoading: _isLoading,
                        child: const Text('Daftar Sekarang'),
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
                        onPressed: _signUpWithGoogle,
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
                            const Text('Daftar dengan Google'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah memiliki akun? ',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryBlue,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Masuk Sekarang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}
