import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../routes/app_routes.dart';
import '../utils/logger.dart';
import '../widgets/my_button.dart';
import '../constants/app_theme.dart';
import 'dart:ui';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

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
  final double _indicatorExtent = 0;
  bool _showPassword = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // First check if the email exists and how it can be used to sign in
        final signInMethods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(_emailController.text.trim());

        if (signInMethods.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Akun belum terdaftar. Silakan daftar terlebih dahulu.'),
              backgroundColor: Colors.red,
            ));
            setState(() => _isLoading = false);
          }
          return;
        }

        // If this email uses Google Sign In, show appropriate message
        if (signInMethods.contains('google.com') &&
            !signInMethods.contains('password')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Akun ini terdaftar dengan Google. Silakan gunakan tombol "Masuk dengan Google".'),
              backgroundColor: Colors.red,
            ));
            setState(() => _isLoading = false);
          }
          return;
        }

        // Proceed with email/password login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getErrorMessage(e.code)),
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
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Mendapatkan akun Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Mendapatkan autentikasi dari akun Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Melakukan sign-in ke Firebase dengan kredensial
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Mengecek apakah pengguna baru atau sudah terdaftar
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Jika pengguna baru, logout dan tampilkan pesan
        await FirebaseAuth.instance.signOut();
        await googleSignIn.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Akun belum terdaftar. Silakan daftar terlebih dahulu.'),
            backgroundColor: Colors.red,
          ));
        }

        setState(() => _isLoading = false);
        return;
      }

      // Jika pengguna sudah terdaftar, lanjutkan ke halaman beranda
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      AppLogger.error('Google Sign In error', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal masuk dengan Google. Silakan coba lagi.'),
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

  void _resetForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    // Clear any error messages by removing the SnackBar
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Shortened delay
    if (mounted) {
      setState(() {
        _resetForm();
      });

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black45,
        transitionDuration:
            const Duration(milliseconds: 150), // Faster transition
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
                backgroundColor: Colors.transparent, // Transparent background
                elevation: 0, // No shadow
                content: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(
                            milliseconds: 600), // Shorter animation
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

      // Shorter display duration
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
                backgroundColor: isDark
                    ? AppTheme.darkBackground
                    : const Color.fromARGB(255, 207, 174, 174),
                height: 100,
                animSpeedFactor: 2,
                showChildOpacityTransition: false,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            hintText: 'nama@example.com',
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
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'Kata Sandi',
                            hintText: 'Masukkan kata sandi',
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
      ),
    );
  }
}
