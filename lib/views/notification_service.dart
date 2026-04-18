
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ── NotificationService ──────────────────────────────────────────────────────
/// When you send a notification from Firebase Console with custom data fields:
///   title, body, category, readTime, route
/// The service automatically saves it to Firestore newsletter_articles
/// so it appears in the Newsletter screen feed for all users.
///
/// Custom data fields to fill in Firebase Console:
///   route      → /newsletter
///   category   → Awareness | Tips | Health
///   readTime   → e.g. 5 min read
///   saveArticle → true   ← this triggers saving to Firestore

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // ── Global navigator key — wired to MaterialApp in main.dart ─
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // FCM Topic names
  static const String _topicTips      = 'awareness_tips';
  static const String _topicArticles  = 'health_articles';
  static const String _topicReminders = 'reminders';

  // ── Initialize ───────────────────────────────────────────────
  static Future<void> initialize() async {
    // 1. Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('[NotificationService] Permission: ${settings.authorizationStatus}');

    // 2. Setup local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Create Android notification channel
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
      'breastcare_channel',
      'BreastCare AI',
      description: 'Breast cancer awareness tips and health articles',
      importance: Importance.high,
    ));

    // 4. Save FCM token
    await _saveToken();

    // 5. Listen for token refresh
    _fcm.onTokenRefresh.listen(_updateToken);

    // 6. Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. Background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 8. Terminated app tap
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _saveArticleFromMessage(initialMessage);
      _navigateToRoute(initialMessage.data['route']);
    }
  }

  // ── Subscribe to topics ───────────────────────────────────────
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

  // ── Save FCM token ────────────────────────────────────────────
  static Future<void> _saveToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('[NotificationService] FCM token saved');
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
        .update({
      'fcmToken': token,
      'fcmUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Save article from notification data to Firestore ─────────
  // Only saves if custom data contains saveArticle=true
  static Future<void> _saveArticleFromMessage(RemoteMessage message) async {
    try {
      final data = message.data;

      // Only save if you explicitly set saveArticle=true in custom data
      if (data['saveArticle'] != 'true') return;

      final title    = message.notification?.title ?? data['title'] ?? '';
      final summary  = message.notification?.body  ?? data['summary'] ?? '';
      final category = data['category'] ?? 'Awareness';
      final readTime = data['readTime'] ?? '3 min read';

      if (title.isEmpty) return;

      // Check if article with same title already exists to avoid duplicates
      final existing = await FirebaseFirestore.instance
          .collection('newsletter_articles')
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print('[NotificationService] Article already exists, skipping save');
        return;
      }

      await FirebaseFirestore.instance
          .collection('newsletter_articles')
          .add({
        'title':       title,
        'summary':     summary,
        'category':    category,
        'readTime':    readTime,
        'publishedAt': FieldValue.serverTimestamp(),
        'source':      'notification',
      });

      print('[NotificationService] Article saved to Firestore: $title');
    } catch (e) {
      print('[NotificationService] Failed to save article: $e');
    }
  }

  // ── Foreground message handler ────────────────────────────────
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Save article to Firestore so newsletter feed updates
    await _saveArticleFromMessage(message);

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
          channelDescription:
              'Breast cancer awareness tips and health articles',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFE91E8C),
        ),
      ),
      payload: message.data['route'] ?? '/newsletter',
    );
  }

  // ── Background tap handler ────────────────────────────────────
  static void _handleMessageOpenedApp(RemoteMessage message) async {
    print('[NotificationService] App opened from notification');
    await _saveArticleFromMessage(message);
    _navigateToRoute(message.data['route']);
  }

  // ── Local notification tap handler ────────────────────────────
  static void _onNotificationTapped(NotificationResponse response) {
    print('[NotificationService] Notification tapped: ${response.payload}');
    _navigateToRoute(response.payload);
  }

  // ── Navigate to route ─────────────────────────────────────────
  static void _navigateToRoute(String? route) {
    final target = (route == null || route.isEmpty) ? '/newsletter' : route;
    navigatorKey.currentState?.pushNamed(target);
  }
}