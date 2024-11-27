import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final textSecondaryColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final primary = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [primary, primary.withOpacity(0.8)],
          ).createShader(bounds),
          child: Text(
            'DelConnect',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.chat_bubble, color: primary),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(CupertinoIcons.add, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration:
                isDark ? AppTheme.elevatedCardDark : AppTheme.elevatedCard,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Icon(CupertinoIcons.person, color: primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: textSecondaryColor,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        height: 80,
        backgroundColor: surfaceColor,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: [
          NavigationDestination(
            icon: Icon(CupertinoIcons.home, color: textSecondaryColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.search, color: textSecondaryColor),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.person, color: textSecondaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
