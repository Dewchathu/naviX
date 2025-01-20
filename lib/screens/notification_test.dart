import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationTestPage extends StatefulWidget {
  @override
  _NotificationTestPageState createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initNotificationService();
  }

  Future<void> initNotificationService() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize time zones
    tz.initializeTimeZones();

    // Initialize notification plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Check and request notification permissions
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> scheduleNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 5)); // Notification after 5 seconds

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Test Notification', // Notification title
      'This is a test notification.', // Notification body
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dew_channel_id', // Channel ID
          'Test Channel', // Channel name
          channelDescription: 'Channel for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("Notification scheduled for ${scheduledDate.toLocal()}");
  }

  Future<void> checkNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission is granted')),
      );
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission is denied')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission is permanently denied'),
        ),
      );
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: scheduleNotification,
              child: const Text('Schedule Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkNotificationPermission,
              child: const Text('Check Notification Permission'),
            ),
          ],
        ),
      ),
    );
  }
}
