import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark_aquanix/constants/app_logs.dart';
import 'package:spark_aquanix/backend/model/notification_model.dart';

/// NotificationService handles FCM notification setup, topic subscriptions,
/// displaying notifications when the app is in foreground, and storing notifications locally.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Key for storing notifications in SharedPreferences
  static const String _notificationsKey = 'stored_notifications';

  // Stream controller for notifications updates
  static final _notificationsStreamController =
      StreamController<List<NotificationModel>>.broadcast();

  // Expose stream to listen for notification changes
  static Stream<List<NotificationModel>> get notificationsStream =>
      _notificationsStreamController.stream;

  /// Topic names - define all your topics here
  static const String topicAllUsers = 'all_users';
  static const String topicUpdates = 'updates';
  static const String topicPromotions = 'promotions';

  // Topic prefix for user type
  static const String topicPrefixUserType = 'user_type_';

  // Topic prefix for user region
  static const String topicPrefixRegion = 'region_';

  /// Initialize notification services
  static Future<void> initialize() async {
    // Set up foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications for foreground messages
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        AppLogger.log('Notification tapped: ${response.payload}');
        // You can add navigation logic here if needed
      },
    );

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up background message opened handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
  }

  /// Handle foreground messages by showing a local notification and storing it
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.log('Got a message whilst in the foreground!');
    AppLogger.log('Message data: ${message.data}');

    // Store the notification
    await _storeNotification(message);

    // Show notification if it contains a notification payload
    if (message.notification != null) {
      AppLogger.log(
          'Message also contained a notification: ${message.notification}');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
        payload: message.data.toString(),
      );
    }
  }

  /// Handle when a notification is tapped to open the app from background
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    AppLogger.log('Notification opened app from background state');
    // Store the notification if it doesn't exist yet
    await _storeNotification(message);

    // Here you can add logic to navigate to a specific screen based on the notification
    // For example, using a navigation service or global navigator key
  }

  /// Handle when app is opened from terminated state via notification
  static Future<void> _handleInitialMessage(RemoteMessage message) async {
    AppLogger.log('App opened from terminated state via notification');
    // Store the notification if it doesn't exist yet
    await _storeNotification(message);

    // Here you can add logic to navigate to a specific screen based on the notification
    // This usually needs to be handled in your main.dart after initialization
  }

  /// Store notification in SharedPreferences
  static Future<void> _storeNotification(RemoteMessage message) async {
    try {
      // Only store notifications that have a title/body
      if (message.notification?.title == null &&
          message.notification?.body == null) {
        return;
      }

      // Convert FCM message to our NotificationModel
      final newNotification = NotificationModel.fromRemoteMessage(message);

      // Get existing notifications
      final notifications = await getNotifications();

      // Check if this notification (by ID) already exists
      final existingIndex =
          notifications.indexWhere((n) => n.id == newNotification.id);
      if (existingIndex >= 0) {
        return; // Notification already stored
      }

      // Add new notification to the list
      notifications.insert(
          0, newNotification); // Add at the beginning (newest first)

      // Save updated list
      final prefs = await SharedPreferences.getInstance();
      final encodedList =
          jsonEncode(notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_notificationsKey, encodedList);

      // Notify listeners of the update
      _notificationsStreamController.add(notifications);

      AppLogger.log('Notification stored: ${newNotification.title}');
    } catch (e) {
      AppLogger.log('Error storing notification: $e');
    }
  }

  /// Get all stored notifications
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedData = prefs.getString(_notificationsKey);

      if (storedData == null || storedData.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(storedData);
      return decodedList
          .map((item) => NotificationModel.fromJson(item))
          .toList();
    } catch (e) {
      AppLogger.log('Error getting notifications: $e');
      return [];
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((notification) => !notification.isRead).length;
  }

  /// Mark a notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      final encodedList =
          jsonEncode(updatedNotifications.map((n) => n.toJson()).toList());
      await prefs.setString(_notificationsKey, encodedList);

      // Notify listeners of the update
      _notificationsStreamController.add(updatedNotifications);

      AppLogger.log('Notification marked as read: $notificationId');
    } catch (e) {
      AppLogger.log('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications = notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final encodedList =
          jsonEncode(updatedNotifications.map((n) => n.toJson()).toList());
      await prefs.setString(_notificationsKey, encodedList);

      // Notify listeners of the update
      _notificationsStreamController.add(updatedNotifications);

      AppLogger.log('All notifications marked as read');
    } catch (e) {
      AppLogger.log('Error marking all notifications as read: $e');
    }
  }

  /// Clear all notifications
  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);

      // Notify listeners of the update
      _notificationsStreamController.add([]);

      AppLogger.log('All notifications cleared');
    } catch (e) {
      AppLogger.log('Error clearing notifications: $e');
    }
  }

  /// Remove a specific notification
  static Future<void> removeNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications = notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final encodedList =
          jsonEncode(updatedNotifications.map((n) => n.toJson()).toList());
      await prefs.setString(_notificationsKey, encodedList);

      // Notify listeners of the update
      _notificationsStreamController.add(updatedNotifications);

      AppLogger.log('Notification removed: $notificationId');
    } catch (e) {
      AppLogger.log('Error removing notification: $e');
    }
  }

  /// Subscribe to default topics that all users should receive
  static Future<void> subscribeToDefaultTopics() async {
    try {
      // Subscribe to general topics
      await _messaging.subscribeToTopic(topicAllUsers);
      await _messaging.subscribeToTopic(topicUpdates);

      AppLogger.log('Subscribed to default topics');
    } catch (e) {
      AppLogger.log('Error subscribing to default topics: $e');
    }
  }

  /// Unsubscribe from all topics when user logs out
  static Future<void> unsubscribeFromAllTopics() async {
    try {
      await _messaging.unsubscribeFromTopic(topicAllUsers);
      await _messaging.unsubscribeFromTopic(topicUpdates);
      await _messaging.unsubscribeFromTopic(topicPromotions);

      AppLogger.log('Unsubscribed from all topics');
    } catch (e) {
      AppLogger.log('Error unsubscribing from all topics: $e');
    }
  }

  /// Get FCM token for current device (useful for sending targeted notifications)
  static Future<String?> getDeviceToken() async {
    return await _messaging.getToken();
  }

  /// Add notification settings to user preferences
  static Future<void> updateNotificationPreferences({
    required bool enablePromotions,
  }) async {
    // Save user preferences (implement your own logic here)
    // This is just an example

    // Then update topic subscriptions accordingly
    if (enablePromotions) {
      await _messaging.subscribeToTopic(topicPromotions);
    } else {
      await _messaging.unsubscribeFromTopic(topicPromotions);
    }
  }
}
