import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createPost({
    required String caption,
    required List<File> images,
  }) async {
    try {
      final String userId = _auth.currentUser!.uid;
      final List<String> imageUrls = [];

      // Upload images to Supabase Storage
      for (var image in images) {
        final String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg';
        final String filePath = 'posts/$userId/$fileName';

        // Read file as bytes
        final bytes = await image.readAsBytes();

        // Upload file to Supabase
        await _supabase.storage.from('posts').uploadBinary(filePath, bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
            ));

        // Get public URL
        final String imageUrl =
            _supabase.storage.from('posts').getPublicUrl(filePath);

        imageUrls.add(imageUrl);
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Create post document
      await _firestore.collection('posts').add({
        'userId': userId,
        'userName': '${userData['firstName']} ${userData['lastName']}',
        'userImage': userData['profileImage'] ?? '',
        'caption': caption,
        'images': imageUrls,
        'likes': [],
        'comments': [],
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update user's post count
      await _firestore.collection('users').doc(userId).update({
        'posts_count': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Stream<QuerySnapshot> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> likePost(String postId) async {
    final String userId = _auth.currentUser!.uid;
    final docRef = _firestore.collection('posts').doc(postId);

    final doc = await docRef.get();
    final likes = List<String>.from(doc.data()?['likes'] ?? []);

    if (likes.contains(userId)) {
      await docRef.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final String userId = _auth.currentUser!.uid;

      // Get post data
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      final postData = postDoc.data() as Map<String, dynamic>;

      // Delete images from Supabase storage
      final List<String> imageUrls = List<String>.from(postData['images']);
      for (var url in imageUrls) {
        // Extract file path from URL
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        final filePath =
            pathSegments.sublist(pathSegments.indexOf('posts')).join('/');

        // Delete file from Supabase
        await _supabase.storage.from('posts').remove([filePath]);
      }

      // Delete post document
      await _firestore.collection('posts').doc(postId).delete();

      // Update user's post count
      await _firestore.collection('users').doc(userId).update({
        'posts_count': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
