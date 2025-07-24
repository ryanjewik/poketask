import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // ✅ Define the plugin instance
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ✅ Initialization method
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final String localTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone));
    debugPrint('[NotificationService] Using local timezone: $localTimeZone');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // Android notification channel setup
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminders_channel',
      'Reminders',
      description: 'Notification channel for task reminders',
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Android 13+ notification permission check
    bool? granted;
    if (Platform.isAndroid) {
      try {
        final int sdkInt = int.parse(Platform.version.split(".").first);
        if (sdkInt >= 33) {
          final status = await Permission.notification.request();
          granted = status.isGranted;
          debugPrint('[NotificationService] Notification permission status: $status');
        } else {
          granted = true;
        }
      } catch (e) {
        debugPrint('[NotificationService] Error requesting Android notification permission: $e');
        granted = null;
      }
    } else {
      granted = true;
    }
    if (granted == false) {
      debugPrint('🔴 Notification permission denied');
    }
  }

  // ✅ Request notification permissions
  static Future<void> requestPermissions() async {
    debugPrint('[NotificationService] Requesting notification permissions...');
    // iOS permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    // Android 13+ POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      try {
        final int sdkInt = int.parse(Platform.version.split(".").first);
        debugPrint('[NotificationService] Android SDK version: '
            '[32m$sdkInt[0m');
        if (sdkInt >= 33) {
          final status = await Permission.notification.request();
          debugPrint('[NotificationService] Notification permission status: '
              '[33m$status[0m');
        }
      } catch (e) {
        debugPrint('[NotificationService] Error requesting Android notification permission: '
            '[31m$e[0m');
      }
    }
  }

  // ✅ Schedule a notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Skipping notification: date is in the past ([33m$scheduledTime[0m)');
      return;
    }
    final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    debugPrint('[NotificationService] Scheduling notification: '
        'id=$id, title="$title", body="$body", scheduledTime=$scheduledTime');
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Reminders',
            channelDescription: 'Notification channel for task reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),
        ),
        payload: 'default_payload',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      debugPrint('[NotificationService] Notification scheduled successfully.');
    } on PlatformException catch (e) {
      debugPrint('[NotificationService] PlatformException while scheduling notification: '
          '\u001b[31m[31m${e.code}: ${e.message}\u001b[0m');
      if (e.code == 'exact_alarms_not_permitted') {
        await ensureExactAlarmPermission();
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint('[NotificationService] Error while scheduling notification: '
          '\u001b[31m$e\u001b[0m');
      rethrow;
    }
  }

  /// Opens the system settings for exact alarm permission (Android 12+)
  static Future<void> ensureExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final intent = const AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    }
  }
}
