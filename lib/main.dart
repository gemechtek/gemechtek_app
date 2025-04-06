import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:spark_aquanix/app/app_theme.dart';
import 'package:spark_aquanix/app/providers.dart';
import 'package:spark_aquanix/backend/providers/auth_provider.dart';
import 'package:spark_aquanix/firebase_options.dart';
import 'package:spark_aquanix/navigation/main_navigation.dart';
import 'package:spark_aquanix/view/auth/login.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await auth.FirebaseAuth.instance.setLanguageCode('en-IN');

  // Set up FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // await FirebaseAppCheck.instance.activate(
  //   // androidProvider: AndroidProvider.playIntegrity,
  //   androidProvider: AndroidProvider.debug,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'Spark Aquanix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.isAuthenticated
            ? const MainNavigationScreen()
            : const LoginScreen();
      },
    );
  }
}
