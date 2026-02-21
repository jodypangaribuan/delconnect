import 'dart:ui';

import 'package:delconnect/providers/theme_provider.dart';
import 'package:delconnect/screens/message_screen.dart';
import 'package:delconnect/screens/profile_screen.dart';
import 'package:delconnect/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:delconnect/screens/notification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:intl/intl.dart';

import '../constants/app_theme.dart';
import '../providers/navigation_state.dart';
import '../widgets/navigation.dart';
import '../screens/create_post_screen.dart';
import '../services/post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _hideBottomBarAnimController;
  final bool _isScrolled = false;
  bool _isScrollingDown = false;
  double _lastScrollPosition = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _hideBottomBarAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hideBottomBarAnimController.value =
        1.0; // Add this line to show bottom bar initially
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
    if (!mounted) return;

    final currentScrollPosition = _scrollController.position.pixels;

    // Hanya update bottom navigation bar visibility
    if ((currentScrollPosition > _lastScrollPosition) && !_isScrollingDown) {
      setState(() {
        _isScrollingDown = true;
      });
    } else if ((currentScrollPosition < _lastScrollPosition) &&
        _isScrollingDown) {
      setState(() {
        _isScrollingDown = false;
      });
    }

    _lastScrollPosition = currentScrollPosition;
  }

  Future<void> _handleRefresh() async {
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Gunakan post-frame callback untuk menampilkan dialog
    SchedulerBinding.instance.addPostFrameCallback((_) {
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
    });
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
                bottom: false,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildAppBar(),
                    _buildStories(),
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        bottom: kBottomNavigationBarHeight + 20,
                      ),
                      sliver: _buildPosts(),
                    ),
                  ],
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
            floatingActionButton: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreatePostScreen()),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
                child: const Icon(
                  Iconsax.add,
                  color: Colors.white,
                ),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDark(context);

    final List<Map<String, dynamic>> dummyPosts = [
      {
        'id': 'post1',
        'userName': 'DelConnect Admin',
        'userImage': 'https://picsum.photos/seed/user4/200/200',
        'caption': 'Selamat datang di DelConnect! Mari kita saling terhubung 🚀',
        'images': [
          'https://picsum.photos/seed/post4/600/400',
          'https://picsum.photos/seed/post5/600/400'
        ],
        'likes': ['user1', 'user2', 'user3', 'user4', 'user5'],
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
      },
      {
        'id': 'post2',
        'userName': 'Budi Santoso',
        'userImage': 'https://picsum.photos/seed/user1/200/200',
        'caption': 'Menikmati pemandangan alam yang sangat indah hari ini! #nature #peace',
        'images': ['https://picsum.photos/seed/post1/600/400'],
        'likes': ['user1', 'user2', 'user3'],
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'id': 'post3',
        'userName': 'Siti Aminah',
        'userImage': 'https://picsum.photos/seed/user2/200/200',
        'caption': 'Ngopi pagi dulu biar semangat kerjanya ☕',
        'images': ['https://picsum.photos/seed/post2/600/400'],
        'likes': ['user1', 'user4'],
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
      },
      {
        'id': 'post4',
        'userName': 'Andi Pratama',
        'userImage': 'https://picsum.photos/seed/user3/200/200',
        'caption': 'Waktu yang tepat untuk bersantai dan membaca buku favorit.',
        'images': ['https://picsum.photos/seed/post3/600/400'],
        'likes': ['user2'],
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = dummyPosts[index];
          final likes = List<String>.from(post['likes'] ?? []);
          final isLiked = false;

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: post['userImage'] != null &&
                                post['userImage'].isNotEmpty
                            ? NetworkImage(post['userImage'])
                            : null,
                        child: post['userImage'] == null ||
                                post['userImage'].isEmpty
                            ? Text(post['userName'][0].toUpperCase())
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['userName'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            if (post['timestamp'] != null)
                              Text(
                                _getTimeAgo(post['timestamp'].toDate()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.more,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Post Images
                if (post['images'] != null &&
                    (post['images'] as List).isNotEmpty)
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: (post['images'] as List).length,
                      itemBuilder: (context, imageIndex) {
                        return Image.network(
                          post['images'][imageIndex],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? Colors.white70 : Colors.black45,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading image: $error');
                            return Center(
                              child: Icon(
                                Icons.error_outline,
                                color: isDark ? Colors.white60 : Colors.black45,
                                size: 32,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {}, // Dummy action
                        child: Icon(
                          isLiked ? Iconsax.heart5 : Iconsax.heart,
                          color: isLiked
                              ? Colors.red
                              : (isDark ? Colors.white : Colors.black),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Iconsax.message,
                        color: isDark ? Colors.white : Colors.black,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Iconsax.share,
                        color: isDark ? Colors.white : Colors.black,
                        size: 28,
                      ),
                    ],
                  ),
                ),

                // Likes
                if (likes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${likes.length} suka',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                // Caption
                if (post['caption'] != null && post['caption'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '${post['userName']} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: post['caption']),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        childCount: dummyPosts.length,
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('d MMM').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}h yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  Widget _buildIconButton(IconData icon, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDark(context);
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
      'Quality time bareng squad di danau Toba �� #PenggunaVibes #TobaLife',
      'Grinding tugas di perpus, siapa yang sama? 📚 #MahasiswaKuat #ITDel',
      'Moment seru di kantin, makan bareng teman-teman 🍱 #PenggunaMoments',
      'Praktikum hari ini, semangat guys! 💻 #TeknikITDel #CodingLife',
      'Break time di taman kampus, asik banget! 🌿 #CampusLife #ITDel',
      'Persiapan UTS, semangat Pengguna! 📝 #BelajarBareng #KampusITDel',
      'Sharing ilmu bareng teman-teman di lab 🔬 #SharingIsCaring #PenggunaSpirit',
    ];
    return captions[index % captions.length];
  }

  void _showDeleteConfirmation(
      BuildContext context, String postId, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Hapus Postingan',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus postingan ini?',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              try {
                await PostService().deletePost(postId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Postingan berhasil dihapus'),
                      backgroundColor:
                          isDark ? AppTheme.darkSurface : Colors.black87,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  // Refresh posts
                  setState(() {});
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
