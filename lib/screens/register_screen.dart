import 'dart:async';
import 'dart:ui'; // Add this import at the top

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../utils/logger.dart';
import '../widgets/my_button.dart';
import '../constants/app_theme.dart';
import '../providers/theme_provider.dart';

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
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  final double _indicatorExtent = 0;
  bool _showPassword = false;

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

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

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

      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.signOut();
        AppLogger.log('Google Sign Out successful');
      } catch (e) {
        AppLogger.log('Google Sign Out failed', e);
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.log('Google Sign In cancelled by user');
        setState(() => _isLoading = false);
        return;
      }

      // Check if email already exists
      try {
        final signInMethods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(googleUser.email);
        if (signInMethods.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Email sudah terdaftar. Silakan login.'),
              backgroundColor: Colors.red,
            ));
          }
          setState(() => _isLoading = false);
          return;
        }
      } catch (e) {
        AppLogger.error('Error checking existing user', e);
        setState(() => _isLoading = false);
        return;
      }

      // Get Google Auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Create user with Google credential
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      AppLogger.log('Account creation successful', userCredential.user?.email);

      // Sign out immediately after creating account
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        // Show success message and navigate back to login
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Akun Google berhasil dibuat. Silakan login.'),
          backgroundColor: Colors.green,
        ));

        Navigator.pop(context); // Return to login screen
      }
    } catch (e, stack) {
      AppLogger.error('Sign Up error', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign up error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    // Clear any error messages by removing the SnackBar
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _resetForm();
      });

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, anim1, anim2) => Container(),
        transitionBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: anim1,
                curve: Curves.easeOutBack,
              ),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                content: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: value * 2 * 3.14,
                            child: const Icon(
                              Iconsax.refresh, // Replace refresh_rounded
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Halaman disegarkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
          );
        },
      );

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
              child: LiquidPullToRefresh(
                onRefresh: _handleRefresh,
                color: isDark
                    ? AppTheme.darkBorder
                    : AppTheme.primaryBlue.withOpacity(0.1),
                backgroundColor:
                    isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
                height: 100,
                animSpeedFactor: 2,
                showChildOpacityTransition: false,
                springAnimationDurationInMilliseconds: 800,
                borderWidth: 2,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                  fillColor: isDark
                                      ? AppTheme.darkInput
                                      : Colors.white,
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
                                    Iconsax.user, // Replace person_outline
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
                                  fillColor: isDark
                                      ? AppTheme.darkInput
                                      : Colors.white,
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
                                    Iconsax.user, // Replace person_outline
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
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: '@username',
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
                              Iconsax
                                  .user_tag, // Changed from Iconsax.user to Iconsax.user_tag
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
                            color:
                                isDark ? AppTheme.darkText : Colors.grey[700],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username wajib diisi';
                            }
                            if (value.length < 3) {
                              return 'Username minimal 3 karakter';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                              return 'Username hanya boleh huruf, angka, dan underscore';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'email-kamu@students.del.ac.id',
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
                              Iconsax.sms, // Replace email_outlined
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
                            color:
                                isDark ? AppTheme.darkText : Colors.grey[700],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!value.endsWith('@students.del.ac.id')) {
                              return 'Gunakan email students.del.ac.id';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'Kata Sandi',
                            hintText: 'Min. 8 karakter',
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
                              Iconsax.lock, // Replace lock_outline
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : const Color(0xFF64748B),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? Iconsax.eye : Iconsax.eye_slash,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : const Color(0xFF64748B),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? AppTheme.darkText : Colors.grey[700],
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
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
      ),
    );
  }
}
