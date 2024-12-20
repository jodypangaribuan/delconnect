import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'chat_screen.dart';
import 'dart:ui';

class NewMessageScreen extends StatelessWidget {
  NewMessageScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark),
              _buildSearchBar(isDark),
              Expanded(
                child: _buildUserList(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Iconsax.arrow_left,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Pesan Baru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Cari pengguna...',
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
    );
  }

  Widget _buildUserList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final userData = doc.data() as Map<String, dynamic>;
            // Don't show current user
            if (doc.id == _auth.currentUser?.uid)
              return const SizedBox.shrink();

            return _buildUserItem(context, doc.id, userData, isDark);
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserItem(BuildContext context, String userId,
      Map<String, dynamic> userData, bool isDark) {
    final String fullName = '${userData['firstName']} ${userData['lastName']}';
    final String username = userData['username'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            fullName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        title: Text(
          fullName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '@$username',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
          ),
        ),
        onTap: () async {
          // Get or create chat room ID
          String chatRoomId = _getChatRoomId(
            FirebaseAuth.instance.currentUser!.uid,
            userId,
          );

          // Check if chat room exists or create it
          final chatRoomRef = FirebaseFirestore.instance
              .collection('chat_rooms')
              .doc(chatRoomId);

          if (!(await chatRoomRef.get()).exists) {
            // Create new chat room
            await chatRoomRef.set({
              'participants': [FirebaseAuth.instance.currentUser!.uid, userId],
              'lastMessage': null,
              'lastMessageTime': null,
              'participantDetails': {
                FirebaseAuth.instance.currentUser!.uid: {
                  'firstName': (await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get())
                      .data()!['firstName'],
                  'lastName': (await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get())
                      .data()!['lastName'],
                },
                userId: {
                  'firstName': userData['firstName'],
                  'lastName': userData['lastName'],
                },
              },
            });
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverId: userId,
                receiverName: fullName,
                chatRoomId: chatRoomId, // Add this parameter
              ),
            ),
          );
        },
      ),
    );
  }

  // Add this helper method
  String _getChatRoomId(String userId1, String userId2) {
    // Sort the ids to ensure consistency
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }
}
