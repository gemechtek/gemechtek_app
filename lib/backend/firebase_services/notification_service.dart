import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spark_aquanix/constants/app_logs.dart';

/// NotificationService handles FCM notification setup, topic subscriptions,
/// and displaying notifications when the app is in foreground.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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
  }

  /// Handle foreground messages by showing a local notification
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.log('Got a message whilst in the foreground!');
    AppLogger.log('Message data: ${message.data}');

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

  /// Subscribe to default topics that all users should receive
  static Future<void> subscribeToDefaultTopics() async {
    try {
      // Subscribe to general topics
      await _messaging.subscribeToTopic(topicAllUsers);
      await _messaging.subscribeToTopic(topicUpdates);

      AppLogger.log('Subscribed to default topics');

      // Subscribe to additional topics based on user data
      await subscribeToUserSpecificTopics();
    } catch (e) {
      AppLogger.log('Error subscribing to default topics: $e');
    }
  }

  /// Subscribe to topics based on current user's data
  static Future<void> subscribeToUserSpecificTopics() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // You can get user-specific data from your user profile here
      // This is just an example - modify according to your data structure

      // Example: Subscribe to user type topic (if you have a user type in your database)
      final userType = await _getUserType();
      if (userType.isNotEmpty) {
        await _messaging.subscribeToTopic('$topicPrefixUserType$userType');
        AppLogger.log(
            'Subscribed to user type topic: $topicPrefixUserType$userType');
      }

      // Example: Subscribe to region topic (if you have user region in your database)
      final userRegion = await _getUserRegion();
      if (userRegion.isNotEmpty) {
        await _messaging.subscribeToTopic('$topicPrefixRegion$userRegion');
        AppLogger.log(
            'Subscribed to region topic: $topicPrefixRegion$userRegion');
      }

      // Unsubscribe from promotions if user has opted out
      final hasOptedOutOfPromotions = await _hasOptedOutOfPromotions();
      if (!hasOptedOutOfPromotions) {
        await _messaging.subscribeToTopic(topicPromotions);
      } else {
        await _messaging.unsubscribeFromTopic(topicPromotions);
      }
    } catch (e) {
      AppLogger.log('Error subscribing to user-specific topics: $e');
    }
  }

  /// Update topic subscriptions when user data changes
  static Future<void> updateUserTopics() async {
    // First unsubscribe from all user-specific topics
    await _unsubscribeFromUserSpecificTopics();

    // Then resubscribe based on current data
    await subscribeToUserSpecificTopics();
  }

  /// Unsubscribe from all non-default topics
  static Future<void> _unsubscribeFromUserSpecificTopics() async {
    try {
      // Get list of user types and regions to unsubscribe from
      // This is simplified - you might need to track subscribed topics
      final userTypes = ['free', 'premium', 'trial'];
      final regions = ['india', 'us', 'europe', 'asia'];

      // Unsubscribe from all possible user type topics
      for (final type in userTypes) {
        await _messaging.unsubscribeFromTopic('$topicPrefixUserType$type');
      }

      // Unsubscribe from all possible region topics
      for (final region in regions) {
        await _messaging.unsubscribeFromTopic('$topicPrefixRegion$region');
      }

      // Unsubscribe from promotions
      await _messaging.unsubscribeFromTopic(topicPromotions);
    } catch (e) {
      AppLogger.log('Error unsubscribing from user-specific topics: $e');
    }
  }

  /// Unsubscribe from all topics when user logs out
  static Future<void> unsubscribeFromAllTopics() async {
    try {
      await _messaging.unsubscribeFromTopic(topicAllUsers);
      await _messaging.unsubscribeFromTopic(topicUpdates);
      await _messaging.unsubscribeFromTopic(topicPromotions);

      // Also unsubscribe from any user-specific topics
      await _unsubscribeFromUserSpecificTopics();

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

  // HELPER METHODS - Implement these methods according to your app's data structure

  /// Get user type from your database
  static Future<String> _getUserType() async {
    // TODO: Implement this method based on your database structure
    // Example: Query Firestore for user type
    // For now, returning a default value
    return 'standard'; // Example: 'free', 'premium', etc.
  }

  /// Get user region from your database
  static Future<String> _getUserRegion() async {
    // TODO: Implement this method based on your database structure
    // Example: Query Firestore for user region
    // For now, returning a default value
    return 'india'; // Example: 'us', 'europe', 'asia', etc.
  }

  /// Check if user has opted out of promotional notifications
  static Future<bool> _hasOptedOutOfPromotions() async {
    // TODO: Implement this method based on your database structure
    // Example: Query Firestore for user preferences
    // For now, returning a default value
    return false;
  }
}
