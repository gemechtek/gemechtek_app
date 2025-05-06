import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:spark_aquanix/app/app_theme.dart';
import 'package:spark_aquanix/app/providers.dart';
import 'package:spark_aquanix/backend/firebase_services/notification_service.dart';
import 'package:spark_aquanix/constants/app_logs.dart';

import 'package:spark_aquanix/firebase_options.dart';
import 'package:spark_aquanix/navigation/main_navigation.dart';
import 'package:spark_aquanix/view/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/firebase_services/local_pref.dart';

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  AppLogger.log('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await auth.FirebaseAuth.instance.setLanguageCode('en-IN');

  // Set up FCM background handler - this is still needed at startup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notification service (will add this class later)
  await NotificationService.initialize();

  // Check if user is logged in
  final LocalPreferenceService localPrefs = LocalPreferenceService();
  final bool isLoggedIn = await localPrefs.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'Spark Aquanix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: PermissionHandler(isLoggedIn: isLoggedIn),
      ),
    );
  }
}

class PermissionHandler extends StatefulWidget {
  final bool isLoggedIn;

  const PermissionHandler({super.key, required this.isLoggedIn});

  @override
  State<PermissionHandler> createState() => _PermissionHandlerState();
}

class _PermissionHandlerState extends State<PermissionHandler> {
  @override
  void initState() {
    super.initState();

    _requestPermissionsThenNavigate();
  }

  Future<void> _requestPermissionsThenNavigate() async {
    // Request notification permissions
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppLogger.log('User granted permission: ${settings.authorizationStatus}');

    if (widget.isLoggedIn) {
      // Subscribe to topics if user is logged in
      await NotificationService.subscribeToDefaultTopics();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => widget.isLoggedIn
            ? const MainNavigationScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
