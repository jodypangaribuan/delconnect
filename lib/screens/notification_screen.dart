import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
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
                    _buildNotificationsList(isDark),
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
        'Notifikasi',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildNotificationItem(isDark, index),
        childCount: 20,
      ),
    );
  }

  Widget _buildNotificationItem(bool isDark, int index) {
    final notificationType = index % 4;
    final timeAgo = _getRandomTime(index);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            'https://picsum.photos/200?random=${index + 100}',
          ),
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: 'Pengguna ${index + 1} ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: _getNotificationText(notificationType),
                style: TextStyle(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeAgo,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap
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

  String _getNotificationText(int type) {
    switch (type) {
      case 0:
        return 'menyukai postingan Anda.';
      case 1:
        return 'mengomentari postingan Anda: "Keren banget!"';
      case 2:
        return 'mulai mengikuti Anda.';
      case 3:
        return 'membagikan postingan Anda.';
      default:
        return 'berinteraksi dengan profil Anda.';
    }
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
