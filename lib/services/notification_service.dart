import 'dart:convert';
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
import '../models/task.dart';

class NotificationService {
  // ✅ Define the plugin instance
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'reminders_channel';
  static const String _channelName = 'Reminders';
  static const String _channelDescription =
      'Notification channel for task reminders';

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    ),
  );

  /// Reminders are only scheduled this far ahead. [resyncTaskReminders] runs on
  /// every app launch and refills the window, so later occurrences of long
  /// (e.g. recurring) series get picked up as time moves on.
  static const Duration reminderWindow = Duration(days: 30);

  /// Max reminders scheduled by one [resyncTaskReminders] (nearest first).
  static const int maxResyncReminders = 250;

  /// Hard ceiling on pending reminders when [scheduleTaskReminders] adds more
  /// between resyncs. Android (notably Samsung) caps an app at ~500 alarms.
  static const int _maxPendingReminders = 400;

  /// All-day tasks remind at the start of the day and then every 6 hours.
  static const List<int> _allDayReminderHours = <int>[0, 6, 12, 18];

  /// Reminders closer than this are skipped: one-shot schedules must be in the
  /// future or the plugin throws.
  static const Duration _minLeadTime = Duration(seconds: 5);

  static Future<void>? _initFuture;

  /// Android schedule mode for this app session (null = not checked yet).
  static AndroidScheduleMode? _scheduleMode;

  /// Serializes reminder operations so a resync and a per-task update can't
  /// interleave (e.g. a resync re-adding an edited task's stale reminders).
  static Future<void> _queue = Future<void>.value();

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // ✅ Initialization method. Idempotent: it is called from main() and from
  // widgets, and only the first call does any work. Never throws.
  static Future<void> initialize() => _initFuture ??= _initializeGuarded();

  static Future<void> _initializeGuarded() async {
    try {
      await _initializeOnce();
    } catch (e) {
      debugPrint('[NotificationService] Initialization failed: $e');
      _initFuture = null; // allow a later call to retry
    }
  }

  static Future<void> _initializeOnce() async {
    tz.initializeTimeZones();
    try {
      final String localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
      debugPrint('[NotificationService] Using local timezone: $localTimeZone');
    } catch (e) {
      // Scheduling converts the absolute instant, so UTC still fires on time.
      debugPrint('[NotificationService] Could not resolve local timezone, using UTC: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // Android notification channel setup
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );
    await _android?.createNotificationChannel(channel);

    // Permission prompts live in requestPermissions(); initialize() can be hit
    // lazily from scheduling code, so it only reports the current status.
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final status = await Permission.notification.status;
        debugPrint('[NotificationService] Notification permission status: $status');
        if (status.isDenied || status.isPermanentlyDenied) {
          debugPrint('🔴 Notification permission denied');
        }
      } catch (e) {
        debugPrint('[NotificationService] Error reading Android notification permission: $e');
      }
    }
  }

  // ✅ Request notification permissions
  static Future<void> requestPermissions() async {
    debugPrint('[NotificationService] Requesting notification permissions...');
    try {
      // iOS permissions
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      // Android 13+ POST_NOTIFICATIONS permission. permission_handler handles
      // the API level itself (older Android reports granted without a prompt).
      // Note: Platform.version is the Dart version, not the Android SDK level.
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.notification.request();
        debugPrint('[NotificationService] Notification permission status: $status');
      }
    } catch (e) {
      debugPrint('[NotificationService] Error requesting notification permissions: $e');
    }
  }

  // ✅ Schedule a single one-shot notification. Never throws.
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    debugPrint('[NotificationService] Scheduling notification: '
        'id=$id, title="$title", body="$body", scheduledTime=$scheduledTime');
    final bool ok = await _serialized(() => _scheduleOneShot(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          payload: payload,
        ));
    if (ok) {
      debugPrint('[NotificationService] Notification scheduled successfully.');
    }
  }

  // ---- Task reminder API (shared contract) ----
  // None of these throw: failures are logged so callers can fire-and-forget.

  /// Replaces any pending reminders for [task] with fresh ones. No-op for completed tasks.
  static Future<void> scheduleTaskReminders(Task task) {
    return _serialized(() async {
      try {
        final int otherPending = await _cancelTaskRemindersNow(task.taskId);
        final List<_Reminder> reminders = _remindersFor(task, DateTime.now());
        if (reminders.isEmpty) return;

        final int budget = _maxPendingReminders - otherPending;
        if (budget < reminders.length) {
          debugPrint('[NotificationService] Pending reminder limit reached; '
              'scheduling ${budget < 0 ? 0 : budget} of ${reminders.length} '
              'reminder(s) for task ${task.taskId} (rest picked up on next launch).');
        }
        int scheduled = 0;
        for (final reminder in reminders.take(budget < 0 ? 0 : budget)) {
          if (await _scheduleReminder(reminder)) scheduled++;
        }
        debugPrint('[NotificationService] Scheduled $scheduled reminder(s) '
            'for task ${task.taskId}.');
      } catch (e) {
        debugPrint('[NotificationService] Failed to schedule reminders for task '
            '${task.taskId}: $e');
      }
    });
  }

  /// Cancels every pending reminder belonging to [taskId].
  static Future<void> cancelTaskReminders(String taskId) {
    return _serialized(() async {
      try {
        await _cancelTaskRemindersNow(taskId);
      } catch (e) {
        debugPrint('[NotificationService] Failed to cancel reminders for task $taskId: $e');
      }
    });
  }

  /// Clears all pending reminders and reschedules them from [tasks].
  ///
  /// Clearing everything also removes the yearly-repeating alarms that older
  /// builds registered (DateTimeComponents.dateAndTime), which is what made
  /// last year's tasks notify again.
  static Future<void> resyncTaskReminders(List<Task> tasks) {
    final List<Task> snapshot = List<Task>.of(tasks);
    return _serialized(() async {
      if (kIsWeb) return;
      try {
        await initialize();
        // Pending only: reminders already showing in the tray are left alone.
        await _plugin.cancelAllPendingNotifications();

        final DateTime now = DateTime.now();
        final List<_Reminder> candidates = <_Reminder>[
          for (final task in snapshot) ..._remindersFor(task, now),
        ]..sort((a, b) => a.time.compareTo(b.time));

        final Set<int> usedIds = <int>{};
        int scheduled = 0;
        for (final reminder in candidates) {
          if (scheduled >= maxResyncReminders) break;
          if (!usedIds.add(reminder.id)) {
            debugPrint('[NotificationService] Reminder id collision (${reminder.id}) '
                'for task ${reminder.taskId}; skipping.');
            continue;
          }
          if (await _scheduleReminder(reminder)) scheduled++;
        }
        debugPrint('[NotificationService] Resynced reminders: $scheduled scheduled '
            '(${candidates.length} due in the next ${reminderWindow.inDays} days, '
            'cap $maxResyncReminders) from ${snapshot.length} task(s).');
      } catch (e) {
        debugPrint('[NotificationService] Failed to resync task reminders: $e');
      }
    });
  }

  /// Opens the system settings for exact alarm permission (Android 12+).
  /// Call this from an explicit user action only, never from scheduling loops.
  static Future<void> ensureExactAlarmPermission() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final intent = const AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      debugPrint('[NotificationService] Could not open exact alarm settings: $e');
    } finally {
      _scheduleMode = null; // re-check once the user comes back
    }
  }

  // ---- Internals ----

  static Future<T> _serialized<T>(Future<T> Function() op) {
    final Future<T> result = _queue.then((_) => op());
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  /// Cancels [taskId]'s reminders (matched by payload) and returns how many
  /// other reminders are still pending.
  static Future<int> _cancelTaskRemindersNow(String taskId) async {
    if (kIsWeb || taskId.isEmpty) return 0;
    await initialize();
    final List<PendingNotificationRequest> pending =
        await _plugin.pendingNotificationRequests();
    int others = 0;
    for (final request in pending) {
      if (request.payload == taskId) {
        await _plugin.cancel(request.id);
      } else {
        others++;
      }
    }
    return others;
  }

  /// Builds the reminders [task] should have right now, in chronological order.
  static List<_Reminder> _remindersFor(Task task, DateTime now) {
    if (task.isCompleted || task.taskId.isEmpty) return const <_Reminder>[];
    // Only this year's tasks (and future ones) notify; never older tasks.
    if (task.startDate.isBefore(DateTime(now.year))) return const <_Reminder>[];

    final DateTime earliest = now.add(_minLeadTime);
    final DateTime windowEnd = now.add(reminderWindow);
    bool schedulable(DateTime t) => t.isAfter(earliest) && !t.isAfter(windowEnd);

    final String name =
        task.taskText.trim().isEmpty ? 'Untitled task' : task.taskText.trim();
    final List<_Reminder> reminders = <_Reminder>[];
    void add(DateTime time, String title, String body) => reminders.add(_Reminder(
          id: _reminderId(task.taskId, reminders.length),
          taskId: task.taskId,
          time: time,
          title: title,
          body: body,
        ));

    if (!task.isAllDay) {
      final DateTime oneHourBefore =
          task.startDate.subtract(const Duration(hours: 1));
      if (oneHourBefore.isAfter(earliest)) {
        if (schedulable(oneHourBefore)) {
          add(oneHourBefore, 'Upcoming Task', '"$name" starts in 1 hour!');
        }
      } else if (schedulable(task.startDate)) {
        // Too late for the 1-hour heads-up, but it hasn't started yet.
        add(task.startDate, 'Task Starting', '"$name" is starting now!');
      }
      return reminders;
    }

    // All-day: 00:00, 06:00, 12:00, 18:00 on every day the task covers.
    final DateTime lastDay = startOfDay(
        task.endDate.isBefore(task.startDate) ? task.startDate : task.endDate);
    DateTime day = startOfDay(task.startDate);
    final DateTime today = startOfDay(now);
    if (day.isBefore(today)) day = today;
    while (!day.isAfter(lastDay) && !day.isAfter(windowEnd)) {
      for (final int hour in _allDayReminderHours) {
        final DateTime time = DateTime(day.year, day.month, day.day, hour);
        if (schedulable(time)) {
          add(time, "Today's Task", '"$name" is on your list today!');
        }
      }
      // Calendar arithmetic (not +24h) so DST changes don't shift the hours.
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return reminders;
  }

  /// Stable notification id for reminder [index] of [taskId]: 32-bit FNV-1a
  /// over "taskId#index", masked to a non-negative 32-bit signed int.
  /// (String.hashCode is not stable across app runs.)
  static int _reminderId(String taskId, int index) {
    int hash = 0x811c9dc5;
    for (final int byte in utf8.encode('$taskId#$index')) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }

  static Future<bool> _scheduleReminder(_Reminder reminder) => _scheduleOneShot(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledTime: reminder.time,
        payload: reminder.taskId,
      );

  /// Exact alarms if the OS allows them, otherwise inexact. Checked once per
  /// session instead of bouncing the user to settings on every failure.
  static Future<AndroidScheduleMode> _resolveScheduleMode() async {
    final AndroidScheduleMode? cached = _scheduleMode;
    if (cached != null) return cached;
    AndroidScheduleMode mode = AndroidScheduleMode.exactAllowWhileIdle;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final bool? canExact = await _android?.canScheduleExactNotifications();
        if (canExact == false) {
          mode = AndroidScheduleMode.inexactAllowWhileIdle;
          debugPrint('[NotificationService] Exact alarms not permitted; '
              'using inexact reminders this session.');
        }
      } catch (e) {
        debugPrint('[NotificationService] Could not check exact alarm permission: $e');
      }
    }
    _scheduleMode = mode;
    return mode;
  }

  /// Schedules one non-repeating notification. Returns false (and logs)
  /// instead of throwing.
  static Future<bool> _scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (kIsWeb) return false;
    if (!scheduledTime.isAfter(DateTime.now().add(_minLeadTime))) {
      debugPrint('⚠️ Skipping notification: date is in the past ($scheduledTime)');
      return false;
    }
    try {
      await initialize();
      final AndroidScheduleMode mode = await _resolveScheduleMode();
      final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
      try {
        // No matchDateTimeComponents: that makes the plugin repeat the
        // notification (dateAndTime = every year), which is the bug that
        // re-fired last year's tasks.
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tzTime,
          _notificationDetails,
          payload: payload,
          androidScheduleMode: mode,
        );
      } on PlatformException catch (e) {
        if (e.code != 'exact_alarms_not_permitted' ||
            mode == AndroidScheduleMode.inexactAllowWhileIdle) {
          rethrow;
        }
        debugPrint('[NotificationService] Exact alarms not permitted; '
            'falling back to inexact reminders.');
        _scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tzTime,
          _notificationDetails,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
      return true;
    } catch (e) {
      debugPrint('[NotificationService] Error while scheduling notification $id '
          'at $scheduledTime: $e');
      return false;
    }
  }
}

class _Reminder {
  const _Reminder({
    required this.id,
    required this.taskId,
    required this.time,
    required this.title,
    required this.body,
  });

  final int id;
  final String taskId;
  final DateTime time;
  final String title;
  final String body;
}
