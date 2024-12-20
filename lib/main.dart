import 'package:delconnect/firebase_options.dart';
import 'package:delconnect/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'constants/app_theme.dart';
import 'providers/navigation_state.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://csejtbpiwyjesioszdtw.supabase.co',
      anonKey: 'your-anon-key',
      debug: false,
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationService.initialize();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationState()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'DelConnect',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            ...AppRoutes.routes,
          },
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
