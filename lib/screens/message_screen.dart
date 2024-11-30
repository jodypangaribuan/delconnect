import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/navigation_state.dart';
import 'package:iconsax/iconsax.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isScrollingDown = false;
  double _lastScrollPosition = 0;

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
    setState(() => _isScrolled = _scrollController.offset > 0);
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
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
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
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(isDark),
                    _buildSearchBar(isDark),
                    _buildMessagesList(isDark),
                    const SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: kBottomNavigationBarHeight + 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBlurredStatusBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: _isScrolled
          ? (isDark ? Colors.black : Colors.white).withOpacity(0.8)
          : Colors.transparent,
      title: Text(
        'Pesan',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Iconsax.edit,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {},
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

  Widget _buildSearchBar(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Cari pesan...',
              hintStyle: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Iconsax.search_normal,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildMessageItem(isDark, index),
        childCount: 20,
      ),
    );
  }

  Widget _buildMessageItem(bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                'https://picsum.photos/200?random=${index + 100}',
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: index % 3 == 0 ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.black : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          'Pengguna ${index + 1}',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _getRandomMessage(index),
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getRandomTime(index),
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            if (index % 4 == 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          // Handle message tap
        },
      ),
    );
  }

  Widget _buildBlurredStatusBar() {
    return Positioned(
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
    );
  }

  String _getRandomMessage(int index) {
    final messages = [
      'Hey, bagaimana kabarmu?',
      'Jadi kumpul kapan nih?',
      'Tugas sudah selesai kah?',
      'Mari kerjakan project bareng',
      'Sudah lihat pengumuman terbaru?',
      'Besok ada kelas jam berapa?',
      'Mau ikut ke perpus?',
      'Jangan lupa deadline minggu ini',
    ];
    return messages[index % messages.length];
  }

  String _getRandomTime(int index) {
    final times = [
      'Baru saja',
      '5 menit',
      '15 menit',
      '1 jam',
      '2 jam',
      'Kemarin',
      '2 hari',
      '1 minggu',
    ];
    return times[index % times.length];
  }
}
