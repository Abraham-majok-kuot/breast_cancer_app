import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ── NotificationService ──────────────────────────────────────────────────────
/// Handles all Firebase Cloud Messaging (FCM) push notification logic:
///   - Requesting permission from the user
///   - Subscribing / unsubscribing to FCM topics
///   - Saving the FCM token to Firestore
///   - Showing local notifications when app is in foreground
///
/// FCM Topics used:
///   awareness_tips   → weekly breast cancer awareness tips
///   health_articles  → new article published notifications
///   reminders        → monthly assessment reminders
///
/// Setup required:
///   1. Add to pubspec.yaml:
///        firebase_messaging: ^15.0.0
///        flutter_local_notifications: ^17.0.0
///   2. Add to android/app/src/main/AndroidManifest.xml inside <application>:
///        <meta-data
///          android:name="com.google.firebase.messaging.default_notification_channel_id"
///          android:value="breastcare_channel"/>
///   3. Call NotificationService.initialize() in main.dart after Firebase.initializeApp()

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // FCM Topic names — must match what you send from Firebase Console
  static const String _topicTips      = 'awareness_tips';
  static const String _topicArticles  = 'health_articles';
  static const String _topicReminders = 'reminders';

  // ── Initialize (call once in main.dart) ──────────────────────
  static Future<void> initialize() async {
    // 1. Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
     print('[NotificationService] Permission: ${settings.authorizationStatus}');

    // 2. Setup local notifications (for foreground display)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Create notification channel for Android
    await _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
      'breastcare_channel',
      'BreastCare AI',
      description: 'Breast cancer awareness tips and health articles',
      importance: Importance.high,
    ));

    // 4. Save FCM token to Firestore
    await _saveToken();

    // 5. Listen for token refresh
    _fcm.onTokenRefresh.listen(_updateToken);

    // 6. Handle foreground messages — show local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // ── Subscribe to selected topics ─────────────────────────────
  static Future<void> subscribe({
    required bool tips,
    required bool articles,
    required bool reminders,
  }) async {
    if (tips) {
      await _fcm.subscribeToTopic(_topicTips);
    } else {
      await _fcm.unsubscribeFromTopic(_topicTips);
    }

    if (articles) {
      await _fcm.subscribeToTopic(_topicArticles);
    } else {
      await _fcm.unsubscribeFromTopic(_topicArticles);
    }

    if (reminders) {
      await _fcm.subscribeToTopic(_topicReminders);
    } else {
      await _fcm.unsubscribeFromTopic(_topicReminders);
    }

     print('[NotificationService] Topics updated — '
        'tips: $tips, articles: $articles, reminders: $reminders');
  }

  // ── Unsubscribe from all topics ───────────────────────────────
  static Future<void> unsubscribeAll() async {
    await _fcm.unsubscribeFromTopic(_topicTips);
    await _fcm.unsubscribeFromTopic(_topicArticles);
    await _fcm.unsubscribeFromTopic(_topicReminders);
     print('[NotificationService] Unsubscribed from all topics');
  }

  // ── Save FCM token to Firestore ───────────────────────────────
  static Future<void> _saveToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token, 'fcmUpdatedAt': FieldValue.serverTimestamp()});

       print('[NotificationService] FCM token saved to Firestore');
    } catch (e) {
       print('[NotificationService] Failed to save token: $e');
    }
  }

  static Future<void> _updateToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'fcmToken': token, 'fcmUpdatedAt': FieldValue.serverTimestamp()});
  }

  // ── Show local notification when app is in foreground ────────
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      notification.hashCode,
      notification.title ?? 'BreastCare AI',
      notification.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'breastcare_channel',
          'BreastCare AI',
          channelDescription: 'Breast cancer awareness tips and health articles',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFE91E8C),
        ),
      ),
      payload: message.data['route'] ?? '',
    );
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
     print('[NotificationService] App opened from notification: ${message.data}');
    // Navigation can be handled here based on message.data['route']
  }

  static void _onNotificationTapped(NotificationResponse response) {
     print('[NotificationService] Notification tapped: ${response.payload}');
  }
}