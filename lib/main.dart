import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_routes.dart';
import 'constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optimize system settings
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DelConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: '.SF Pro Text',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.lightPrimary,
          background: AppTheme.lightBackground,
          surface: AppTheme.lightSurface,
        ),
        scaffoldBackgroundColor: AppTheme.lightBackground,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            color: AppTheme.lightText,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: AppTheme.lightText,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppTheme.lightTextSecondary,
            letterSpacing: -0.2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppTheme.lightPrimary.withOpacity(0.5)),
          ),
          labelStyle: const TextStyle(color: AppTheme.lightTextSecondary),
          prefixIconColor: AppTheme.lightTextSecondary,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: '.SF Pro Text',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.darkPrimary,
          background: AppTheme.darkBackground,
          surface: AppTheme.darkSurface,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppTheme.darkBackground,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            color: AppTheme.darkText,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: AppTheme.darkText,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppTheme.darkTextSecondary,
            letterSpacing: -0.2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppTheme.darkPrimary.withOpacity(0.5)),
          ),
          labelStyle: const TextStyle(color: AppTheme.darkTextSecondary),
          prefixIconColor: AppTheme.darkTextSecondary,
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
