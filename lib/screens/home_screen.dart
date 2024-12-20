import 'dart:ui';

import 'package:delconnect/providers/theme_provider.dart';
import 'package:delconnect/screens/message_screen.dart';
import 'package:delconnect/screens/profile_screen.dart';
import 'package:delconnect/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:delconnect/screens/notification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../constants/app_theme.dart';
import '../providers/navigation_state.dart';
import '../widgets/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _hideBottomBarAnimController;
  bool _isScrolled = false;
  bool _isScrollingDown = false;
  double _lastScrollPosition = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    _hideBottomBarAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hideBottomBarAnimController.value =
        1.0; // Add this line to show bottom bar initially
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _hideBottomBarAnimController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double currentScrollPosition = _scrollController.position.pixels;

    if ((currentScrollPosition > _lastScrollPosition) && !_isScrollingDown) {
      // Scrolling DOWN
      setState(() {
        _isScrollingDown = true;
      });
    } else if ((currentScrollPosition < _lastScrollPosition) &&
        _isScrollingDown) {
      // Scrolling UP
      setState(() {
        _isScrollingDown = false;
      });
    }

    _lastScrollPosition = currentScrollPosition;

    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        // Reset any state if needed
      });

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, anim1, anim2) => Container(),
        transitionBuilder: (context, anim1, anim2, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

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
                            child: Icon(
                              Iconsax.refresh,
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                              size: 24,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Halaman disegarkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? AppTheme.darkText : AppTheme.lightText,
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
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarColor: Colors.transparent,
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              systemNavigationBarColor: Colors.transparent,
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
            ),
      child: Stack(
        children: [
          Scaffold(
            extendBody: true, // Add this line
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors:
                      isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
                ),
              ),
              child: SafeArea(
                bottom: false, // Add this line
                child: LiquidPullToRefresh(
                  onRefresh: _handleRefresh,
                  color: isDark
                      ? AppTheme.darkBorder
                      : AppTheme.primaryBlue.withOpacity(0.1),
                  backgroundColor:
                      isDark ? AppTheme.darkBackground : Colors.white,
                  height: 100,
                  animSpeedFactor: 2,
                  showChildOpacityTransition: false,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      _buildAppBar(),
                      _buildStories(),
                      SliverPadding(
                        // Wrap _buildPosts with SliverPadding
                        padding: const EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight + 20),
                        sliver: _buildPosts(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              offset:
                  _isScrollingDown ? const Offset(0, 1) : const Offset(0, 0),
              child: SharedBottomNavigation(
                currentIndex: _currentIndex,
                onIndexChanged: (index) =>
                    setState(() => _currentIndex = index),
                isDark: isDark,
              ),
            ),
          ),
          // Add blur effect to status bar area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: MediaQuery.of(context).padding.top,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          // Bottom safe area blur
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: MediaQuery.of(context).padding.bottom,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return SliverAppBar(
      automaticallyImplyLeading: false, // Add this line to remove back button
      floating: true,
      snap: true,
      backgroundColor: _isScrolled
          ? (isDark
              ? AppTheme.darkBackground.withOpacity(0.5)
              : AppTheme.lightBackground.withOpacity(0.5))
          : Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/logo.png',
            height: 32,
          ),
          const SizedBox(width: 8),
          Text(
            'DelConnect',
            style: GoogleFonts.dancingScript(
              // or another Instagram-like font
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Iconsax.heart,
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationScreen()),
            );
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Iconsax.message,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MessageScreen()),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .where('type',
                      isEqualTo: 'message') // Only count message notifications
                  .where('isRead', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${snapshot.data!.docs.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildStories() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return SliverToBoxAdapter(
      child: Container(
        height: 110,
        color: Colors.transparent,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 11, // Increased by 1 to accommodate the add story button
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: isDark
                            ? AppTheme.darkBackground
                            : AppTheme.lightBackground,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              isDark ? Colors.grey[900] : Colors.grey[100],
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Iconsax.story,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[800],
                                  size: 28,
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.shade600,
                                    border: Border.all(
                                      color: isDark
                                          ? AppTheme.darkBackground
                                          : AppTheme.lightBackground,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Iconsax.add,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cerita Kamu', // Changed from 'Your Story'
                      style: TextStyle(
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: isDark ? Colors.black : Colors.white,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/200?random=$index',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pengguna ${index - 1}', // Changed from 'User ${index - 1}'
                    style: TextStyle(
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPosts() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildPostItem(index),
        childCount: 20,
      ),
    );
  }

  Widget _buildPostItem(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                          'https://picsum.photos/200?random=${index + 100}'),
                      onBackgroundImageError: (exception, stackTrace) {
                        return;
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengguna $index', // Changed from 'User $index'
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                            ),
                          ),
                          Text(
                            index % 2 == 0
                                ? 'Baru saja'
                                : 'Kemarin', // Changed from '2h ago'
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement post options
                      },
                    ),
                  ],
                ),
              ),
              Image.network(
                'https://picsum.photos/400/300?random=${index + 200}',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: isDark ? Colors.grey[900] : Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 50,
                      color: isDark ? Colors.grey[700] : Colors.grey[500],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: isDark ? Colors.grey[900] : Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildIconButton(
                                Iconsax.heart,
                                Colors
                                    .white), // Changed from Icons.favorite_border
                            const SizedBox(width: 16),
                            _buildIconButton(
                                Iconsax.message,
                                Colors
                                    .white), // Changed from Icons.chat_bubble_outline
                            const SizedBox(width: 16),
                            _buildIconButton(Iconsax.send_2,
                                Colors.white), // Changed from Icons.send
                          ],
                        ),
                        _buildIconButton(Iconsax.save_2,
                            Colors.white), // Changed from Icons.bookmark_border
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${1234 - index} suka', // Changed from '1,234 likes'
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Pengguna $index ', // Changed from 'User $index'
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: _getRandomCaption(
                                index), // Added random captions
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black87.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat ${48 - index} komentar', // Changed from 'View all 48 comments'
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black87.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isDark ? Colors.black : Colors.white).withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDark ? AppTheme.darkText : AppTheme.lightText,
          size: 20,
        ),
        onPressed: () {
          // TODO: Implement icon actions
        },
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: _isScrollingDown ? const Offset(0, 1) : const Offset(0, 0),
      child: Consumer<NavigationState>(
        builder: (context, navigationState, child) => Container(
          height: kBottomNavigationBarHeight,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white)
                .withOpacity(0.5), // Increased opacity
            border: Border(
              top: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.12),
                width: 0.5,
              ),
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: (isDark ? Colors.black : Colors.white)
                    .withOpacity(0.3), // Adjusted opacity
                child: BottomNavigationBar(
                  currentIndex: navigationState.currentIndex,
                  onTap: (index) {
                    if (index == 1) {
                      // Preserve current index before navigating to search
                      final currentIndex = navigationState.currentIndex;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen()),
                      ).then((_) {
                        // Restore previous index after returning from search
                        context
                            .read<NavigationState>()
                            .updateIndex(currentIndex);
                      });
                    } else {
                      context.read<NavigationState>().updateIndex(index);
                      if (index == 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()),
                        );
                      }
                    }
                  },
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  selectedItemColor:
                      isDark ? AppTheme.darkText : AppTheme.lightText,
                  unselectedItemColor:
                      (isDark ? AppTheme.darkText : AppTheme.lightText)
                          .withOpacity(0.5),
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedFontSize: 10.0,
                  unselectedFontSize: 10.0,
                  iconSize: 24.0,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(
                          Iconsax.home), // Changed from Icons.home_outlined
                      activeIcon:
                          Icon(Iconsax.home_15), // Changed from Icons.home
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Iconsax
                          .search_normal), // Changed from Icons.search_outlined
                      activeIcon: Icon(
                          Iconsax.search_normal_1), // Changed from Icons.search
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Iconsax
                          .discover), // Changed from Icons.explore_outlined
                      activeIcon: Icon(
                          Iconsax.discover_1), // Changed from Icons.explore
                      label: 'Explore',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Iconsax
                          .profile_circle), // Changed from Icons.person_outline_rounded
                      activeIcon: Icon(Iconsax
                          .profile_circle5), // Changed from Icons.person_rounded
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this new method for random captions
  String _getRandomCaption(int index) {
    final List<String> captions = [
      'Suasana seru di kampus hari ini! 🎓 #KampusHijau #ITDel',
      'Quality time bareng squad di danau Toba 🌊 #PenggunaVibes #TobaLife',
      'Grinding tugas di perpus, siapa yang sama? 📚 #MahasiswaKuat #ITDel',
      'Moment seru di kantin, makan bareng teman-teman 🍱 #PenggunaMoments',
      'Praktikum hari ini, semangat guys! 💻 #TeknikITDel #CodingLife',
      'Break time di taman kampus, asik banget! 🌿 #CampusLife #ITDel',
      'Persiapan UTS, semangat Pengguna! 📝 #BelajarBareng #KampusITDel',
      'Sharing ilmu bareng teman-teman di lab 🔬 #SharingIsCaring #PenggunaSpirit',
    ];
    return captions[index % captions.length];
  }
}
