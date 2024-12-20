import 'package:delconnect/screens/chat_screen.dart';
import 'package:delconnect/screens/new_message_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark(context);

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
            Iconsax.message_add,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewMessageScreen()),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('participants',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('Terjadi kesalahan')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.message_text,
                    size: 64,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada percakapan',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildChatItem(
              context,
              snapshot.data!.docs[index],
              isDark,
            ),
            childCount: snapshot.data!.docs.length,
          ),
        );
      },
    );
  }

  Widget _buildChatItem(
      BuildContext context, DocumentSnapshot doc, bool isDark) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String otherUserId = (data['participants'] as List)
        .firstWhere((id) => id != FirebaseAuth.instance.currentUser!.uid);

    // Get the chatRoomId from the document ID
    String chatRoomId = doc.id; // Add this line to get the chatRoomId

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        Map<String, dynamic> userData =
            userSnapshot.data!.data() as Map<String, dynamic>;
        String fullName = '${userData['firstName']} ${userData['lastName']}';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('chatRoomId', isEqualTo: chatRoomId)
              .where('receiverId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where('isRead', isEqualTo: false)
              .snapshots(),
          builder: (context, unreadSnapshot) {
            int unreadCount =
                unreadSnapshot.hasData ? unreadSnapshot.data!.docs.length : 0;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isDark ? Colors.white24 : Colors.black12,
                child: Text(
                  fullName[0].toUpperCase(),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              title: Text(
                fullName,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight:
                      unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                data['lastMessage']?.toString() ?? 'Belum ada pesan',
                style: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    unreadCount > 0 ? 0.9 : 0.6,
                  ),
                  fontWeight:
                      unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              trailing: unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      _getMessageTime(data['lastMessageTime'] as Timestamp?),
                      style: TextStyle(
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      receiverId: otherUserId,
                      receiverName: fullName,
                      chatRoomId: chatRoomId, // Pass the chatRoomId here
                    ),
                  ),
                );
              },
            );
          },
        );
      },
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

  String _getMessageTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      return DateFormat('dd/MM').format(messageTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Baru saja';
    }
  }
}
