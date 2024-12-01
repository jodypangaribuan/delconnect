import 'package:delconnect/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isScrollingDown = false;
  double _lastScrollPosition = 0;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double currentScrollPosition = _scrollController.position.pixels;

    if ((currentScrollPosition > _lastScrollPosition) && !_isScrollingDown) {
      setState(() => _isScrollingDown = true);
    } else if ((currentScrollPosition < _lastScrollPosition) &&
        _isScrollingDown) {
      setState(() => _isScrollingDown = false);
    }

    _lastScrollPosition = currentScrollPosition;

    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarColor: Colors.transparent,
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              systemNavigationBarColor: Colors.transparent,
              statusBarColor: Colors.transparent,
            ),
      child: Stack(
        children: [
          Scaffold(
            extendBody: true,
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
                  slivers: [
                    _buildAppBar(isDark),
                    SliverToBoxAdapter(child: _buildProfileHeader(isDark)),
                    SliverToBoxAdapter(child: _buildStats(isDark)),
                    SliverToBoxAdapter(child: _buildBio(isDark)),
                    SliverPadding(
                      padding: const EdgeInsets.only(
                          bottom: kBottomNavigationBarHeight + 20),
                      sliver: _buildPhotoGrid(isDark),
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
          ),
          // Add blur effects for status bar and bottom safe area
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

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      floating: true,
      pinned: false, // Changed from true
      backgroundColor: _isScrolled
          ? (isDark ? Colors.black : Colors.white).withOpacity(0.8)
          : Colors.transparent,
      expandedHeight: 0, // Removed expandedHeight
      toolbarHeight: 56, // Standard height
      centerTitle: true, // Center the title
      actions: [
        IconButton(
          icon: Icon(
            Iconsax.setting_2,
            color: isDark ? Colors.white : Colors.black,
            size: 24,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blue.shade600],
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
                  radius: 40,
                  backgroundColor: isDark ? Colors.black : Colors.white,
                  child: const CircleAvatar(
                    radius: 38,
                    backgroundImage: NetworkImage('https://picsum.photos/200'),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jody Pangaribuan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '@jody.drian  ',
                      style: TextStyle(
                        fontSize: 16,
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Institut Teknologi Del',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickActions(isDark),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Iconsax.edit_2, 'Edit Profile', isDark),
        _buildActionButton(Iconsax.share, 'Share', isDark),
        _buildActionButton(Iconsax.bookmark, 'Saved', isDark),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('128', 'Postingan', isDark),
          _buildStatDivider(isDark),
          _buildStatItem('1.2K', 'Pengikut', isDark),
          _buildStatDivider(isDark),
          _buildStatItem('845', 'Mengikuti', isDark),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 20,
      width: 1,
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBio(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '11323025 • Teknologi Informasi 23',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mahasiswa IT Del',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MarTuhan, MarRoha, MarBisnis 🎓\nPejuang Deadline 💻\nKampus Hijau 🌱',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://picsum.photos/200?random=$index',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.heart5,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(index + 1) * 11}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: 30,
        ),
      ),
    );
  }
}
