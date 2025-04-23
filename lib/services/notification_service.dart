import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS initialization settings
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true, // Request permission for alerts
      requestBadgePermission: true, // Request permission for badges
      requestSoundPermission: true, // Request permission for sounds
    );

    // Combine platform-specific settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Initialize timezone data for scheduled notifications
    tz.initializeTimeZones();

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Request notification permissions for Android 13+ and iOS
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> scheduleNotification(
      int id,
      String title,
      String body,
      tz.TZDateTime scheduledDate,
      ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dew_channel_id',
          'dew_channel_name',
          channelDescription: 'dew_channel_description',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true, // Show alert
          presentBadge: true, // Update badge
          presentSound: true, // Play sound
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}