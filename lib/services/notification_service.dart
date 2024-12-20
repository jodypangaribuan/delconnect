import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // Ensure Firebase is initialized first
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Request permission with error handling
      try {
        final settings = await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        print(
            'Notification permission status: ${settings.authorizationStatus}');
      } catch (e) {
        print('Error requesting notification permission: $e');
      }

      // Initialize local notifications
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
        },
      );

      // Handle FCM messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Set up foreground notification presentation
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Update FCM token when app starts
      await updateFCMToken();
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  static Future<void> saveNotification({
    required String userId,
    required String type,
    required String message,
    required String senderId,
    required String senderName,
    String? senderImage,
    required String messageId, // Add this
    required String chatRoomId, // Add this
    required bool isRead, // Add this
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': type,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'messageId': messageId, // Add this
      'chatRoomId': chatRoomId, // Add this
      'isRead': isRead, // Add this
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<int> getUnreadCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _showLocalNotification(message);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.data['type'] == 'chat') {
      const androidDetails = AndroidNotificationDetails(
        'chat_channel',
        'Chat Messages',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.show(
        message.data.hashCode,
        message.data['senderName'],
        message.data['message'],
        details,
        payload: jsonEncode(message.data),
      );
    }
  }

  static Future<void> handleChatMessage({
    required String senderId,
    required String senderName,
    required String message,
    required String receiverId,
    required String messageId,
    required String chatRoomId,
  }) async {
    try {
      // Save notification to Firestore
      await saveNotification(
        userId: receiverId,
        type: 'message',
        message: message,
        senderId: senderId,
        senderName: senderName,
        messageId: messageId,
        chatRoomId: chatRoomId,
        isRead: false,
      );

      // Get receiver's FCM token
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();

      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken != null) {
        // Send FCM notification
        await FirebaseMessaging.instance.sendMessage(
          to: fcmToken,
          data: {
            'type': 'chat',
            'senderId': senderId,
            'senderName': senderName,
            'message': message,
            'chatRoomId': chatRoomId,
            'messageId': messageId,
          },
        );
      }
    } catch (e) {
      print('Error handling chat message: $e');
    }
  }

  static Future<void> updateFCMToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'fcmToken': token});
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}

// Add this outside the class
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}
