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
import 'package:app_links/app_links.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize AppLinks
    final appLinks = AppLinks();
    // Handle incoming links
    appLinks.allUriLinkStream.listen((uri) {
      debugPrint('Received uri: $uri');
      // Handle the URI here
    }, onError: (err) {
      debugPrint('Error processing uri: $err');
    });

    await Supabase.initialize(
      url: 'https://csejtbpiwyjesioszdtw.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzZWp0YnBpd3lqZXNpb3N6ZHR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1NTg2MDUsImV4cCI6MjA0OTEzNDYwNX0.ZgeLG3Y7Fb5paVHBDU-bO9UawHpPeyMdBhThoCp0dMY',
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
