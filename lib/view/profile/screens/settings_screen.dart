import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:spark_aquanix/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _receiveNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    setState(() {
      _receiveNotifications = prefs.getBool('receive_notifications') ?? true;
    });
  }

  Future<void> _updateNotificationPreference(bool value) async {
    if (value) {
      // Request notification permission via Firebase Messaging
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      await prefs.setBool('receive_notifications', isGranted);
      setState(() {
        _receiveNotifications = isGranted;
      });

      if (!isGranted) {
        _showPermissionDialog();
      }
    } else {
      await prefs.setBool('receive_notifications', false);
      setState(() {
        _receiveNotifications = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'To receive notifications, you must enable notification permissions from your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseMessaging.instance
                  .requestPermission(); // Optional re-trigger
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Receive Notifications'),
            value: _receiveNotifications,
            onChanged: _updateNotificationPreference,
            secondary: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
    );
  }
}
