import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightPrimary = primaryBlue;
  static const lightAccent = Color(0xFF60A5FA); // Blue-400
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF8FAFC); // Slate-50
  static const lightText = Color(0xFF000000); // Slate-800
  static const lightTextSecondary = Color(0xFF64748B); // Slate-500
  static const lightBorder = Color(0xFFE2E8F0); // Slate-200

  static const Color darkPrimary = primaryBlue;
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkText = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF2D2D2D);
  static const darkInput = Color(0xFF262626);

  static const pastelBlue = Color(0xFFBFDBFE); // Blue-200
  static const pastelIndigo = Color(0xFFC7D2FE); // Indigo-200
  static const pastelSky = Color(0xFFBAE6FD); // Sky-200

  static const gradientLight = [
    Color(0xFFEFF6FF), // Blue-50
    Color(0xFFDBEAFE), // Blue-100
  ];

  static final gradientDark = [
    const Color(0xFF121212),
    const Color(0xFF1E1E1E),
  ];

  static const Color primaryBlue = Color(0xFF107CC4);

  static const profileGradient = [
    Color(0xFFDFE9FA), // Light blue overlay
    Color(0xFFF8FAFC), // Light background
  ];

  static const profileGradientDark = [
    Color(0xFF1E293B), // Dark blue overlay
    Color(0xFF121212), // Dark background
  ];

  // New gradient for story avatars
  static const Gradient storyGradient = LinearGradient(
    colors: [
      Color(0xFFDB36A4),
      Color(0xFFF7FF00),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Updated gradient for better visual appeal
  static const Gradient storyGradientBlue = LinearGradient(
    colors: [
      Color(0xFF1E88E5),
      Color(0xFF64B5F6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background gradient for the app
  static const Gradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF2196F3), // Blue-500
      Color(0xFF64B5F6), // Blue-300
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Add new gradient for the add button
  static const Gradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFF107CC4), // primaryBlue
      Color(0xFF42A5F5), // lighter blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final elevatedCard = BoxDecoration(
    color: lightBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: lightBorder),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      )
    ],
  );

  static final elevatedCardDark = BoxDecoration(
    color: darkSurface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: darkBorder),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      )
    ],
  );

  static const textStyleHeading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const textStyleSubheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const textStyleLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Updated text styles
  static const TextStyle uniqueHeadingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: Colors.white,
  );

  static const TextStyle uniqueBodyTextStyle = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: Colors.white70,
  );

  // Add enhanced text styles for posts
  static const TextStyle postTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle postContentStyle = TextStyle(
    fontSize: 15,
    height: 1.5,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w400,
  );

  // Updated light theme configurations
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightBackground,
    textTheme: TextTheme(
      titleLarge: uniqueHeadingStyle.copyWith(color: lightText),
      bodyMedium: uniqueBodyTextStyle,
      // ...existing text styles...
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 0, // Remove default nav bar
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    ),
    // ...other theme configurations...
  );

  // Updated dark theme configurations
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkBackground,
    textTheme: TextTheme(
      titleLarge: uniqueHeadingStyle.copyWith(color: darkText),
      bodyMedium: uniqueBodyTextStyle.copyWith(color: darkTextSecondary),
      // ...existing text styles...
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 0, // Remove default nav bar
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    ),
    // ...other theme configurations...
  );

  static BoxDecoration commonCardDecoration(bool isDark,
      {double opacity = 0.1}) {
    return BoxDecoration(
      color: (isDark ? Colors.white : Colors.black).withOpacity(opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration commonGradientHeader() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.purple.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static TextStyle headerTextStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle sectionTitleStyle(bool isDark) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      );
}
