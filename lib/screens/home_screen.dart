import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../constants/app_theme.dart';

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
  int _currentIndex = 0; // Add this line

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

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

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
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(),
                    _buildStories(),
                    _buildPosts(),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavBar(isDark),
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
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SliverAppBar(
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
            'assets/logo.png', // Make sure to add your logo in assets
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
            Icons.favorite_border,
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.send_rounded, // Changed from messenger_outline_rounded
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildStories() {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SliverToBoxAdapter(
      child: Container(
        height: 110,
        color: Colors.transparent,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.pink, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.transparent, width: 3),
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://picsum.photos/200?random=${index + 1}'),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) =>
                                const Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User $index',
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
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
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
                            'User $index',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                            ),
                          ),
                          Text(
                            '2h ago',
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
                                Icons.favorite_border, Colors.white),
                            const SizedBox(width: 16),
                            _buildIconButton(
                                Icons.chat_bubble_outline, Colors.white),
                            const SizedBox(width: 16),
                            _buildIconButton(Icons.send, Colors.white),
                          ],
                        ),
                        _buildIconButton(Icons.bookmark_border, Colors.white),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1,234 likes',
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
                            text: 'User $index ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                'This is a sample caption for the post. #flutter #ui #design',
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
                      'View all 48 comments',
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
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
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
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: _isScrollingDown ? const Offset(0, 1) : const Offset(0, 0),
      child: Container(
        height: kBottomNavigationBarHeight,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
              width: 0.5,
            ),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.1),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
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
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_outline),
                    activeIcon: Icon(Icons.favorite),
                    label: 'Activity',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_outlined),
                    activeIcon: Icon(Icons.add_box),
                    label: 'Post',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.messenger_outline_rounded),
                    activeIcon: Icon(Icons.messenger_rounded),
                    label: 'Messages',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
