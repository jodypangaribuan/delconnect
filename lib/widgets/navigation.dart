import 'package:delconnect/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/profile_screen.dart';

class SharedBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final bool isDark;

  const SharedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: kBottomNavigationBarHeight,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
            border: Border(
              top: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.12),
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              if (currentIndex != index) {
                if (index == 1) {
                  // For search screen
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const SearchScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  onIndexChanged(index);
                  String route = AppRoutes.home;
                  switch (index) {
                    case 0:
                      route = AppRoutes.home;
                      break;
                    case 2:
                      route = AppRoutes.explore;
                      break;
                    case 3:
                      route = AppRoutes.profile;
                      break;
                  }
                  Navigator.pushNamedAndRemoveUntil(
                      context, route, (route) => false);
                }
              }
            },
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: isDark ? Colors.white : Colors.black,
            unselectedItemColor:
                (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10.0,
            unselectedFontSize: 10.0,
            iconSize: 24.0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.home),
                activeIcon: Icon(Iconsax.home_15),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.search_normal),
                activeIcon: Icon(Iconsax.search_normal_1),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.discover),
                activeIcon: Icon(Iconsax.discover_1),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.profile_circle),
                activeIcon: Icon(Iconsax.profile_circle5),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const SearchScreen();
      case 2:
        return const ExploreScreen();
      case 3:
        return const ProfileScreen();
      default:
        return null;
    }
  }
}
