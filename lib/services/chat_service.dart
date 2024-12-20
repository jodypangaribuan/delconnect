import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delconnect/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message
  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final chatRoomId = _getChatRoomId(currentUserId, receiverId);

    try {
      // Get sender's name
      final senderDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final senderName =
          '${senderDoc.data()?['firstName']} ${senderDoc.data()?['lastName']}';

      // Send message
      final messageDoc = await _firestore.collection('chats').add({
        'senderId': currentUserId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp,
        'isRead': false,
        'chatRoomId': chatRoomId,
      });

      // Update chat room
      await _updateChatRoom(currentUserId, receiverId, message, timestamp);

      // Send notification
      await NotificationService.handleChatMessage(
        senderId: currentUserId,
        senderName: senderName,
        message: message,
        receiverId: receiverId,
        messageId: messageDoc.id,
        chatRoomId: _getChatRoomId(currentUserId, receiverId),
      );
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages with error handling
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    try {
      String chatRoomId = _getChatRoomId(userId, otherUserId);
      return _firestore
          .collection('chats')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .orderBy('timestamp') // Change to descending order
          .snapshots();
    } catch (e) {
      print('Error getting messages: $e');
      // Return empty stream in case of error
      return const Stream.empty();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('chats').doc(messageId).delete();
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  String _getChatRoomId(String userId1, String userId2) {
    // Sort the ids to ensure consistency
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> _updateChatRoom(String currentUserId, String receiverId,
      String message, Timestamp timestamp) async {
    // Get user data for both participants
    final senderDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final receiverDoc =
        await _firestore.collection('users').doc(receiverId).get();

    final senderData = senderDoc.data() ?? {};
    final receiverData = receiverDoc.data() ?? {};

    // Create or update chat room with user details
    await _firestore
        .collection('chat_rooms')
        .doc(_getChatRoomId(currentUserId, receiverId))
        .set({
      'participants': [currentUserId, receiverId],
      'participantDetails': {
        currentUserId: {
          'firstName': senderData['firstName'] ?? '',
          'lastName': senderData['lastName'] ?? '',
          'username': senderData['username'] ?? '',
        },
        receiverId: {
          'firstName': receiverData['firstName'] ?? '',
          'lastName': receiverData['lastName'] ?? '',
          'username': receiverData['username'] ?? '',
        },
      },
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'lastSender': currentUserId,
    }, SetOptions(merge: true)); // Use merge to preserve existing data
  }

  Future<void> markMessageAsRead(String chatRoomId, String messageId) async {
    try {
      // Mark message as read
      await _firestore
          .collection('chats')
          .doc(messageId)
          .update({'isRead': true});

      // Mark corresponding notification as read
      final notifications = await _firestore
          .collection('notifications')
          .where('messageId', isEqualTo: messageId)
          .get();

      for (var doc in notifications.docs) {
        await doc.reference.update({'isRead': true});
      }

      // Update unread count in chat room
      await _updateUnreadCount(chatRoomId);
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<void> _updateUnreadCount(String chatRoomId) async {
    final unreadMessages = await _firestore
        .collection('chats')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .where('receiverId', isEqualTo: _auth.currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .get();

    await _firestore.collection('chat_rooms').doc(chatRoomId).update({
      'unreadCount': unreadMessages.docs.length,
    });
  }
}

// Message model class
class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
