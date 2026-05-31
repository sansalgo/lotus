import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../database/app_database.dart';

/// Central service for scheduling and cancelling habit reminder notifications.
///
/// Notification ID scheme: habitId * 100 + reminderIndex
/// Supports up to 100 reminders per habit.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _batteryChannel = MethodChannel('com.sansalgo.lotus/battery');

  static const _channelId = 'lotus_habit_reminders';
  static const _channelName = 'Habit Reminders';
  static const _channelDesc = 'Daily reminders for your habits';

  // ── Initialisation ────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_initialized) return;

    // Set up timezone database
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to UTC on failure
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );

    // Explicitly create the Android notification channel so it exists with the
    // correct importance before the first notification is ever scheduled.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    _initialized = true;
  }

  /// Request notification permissions from the OS.
  /// Safe to call multiple times — only prompts once per app lifetime.
  static Future<void> requestPermissions() async {
    await _ensureInitialized();

    // iOS: request alert/badge/sound permissions.
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Android 13+: runtime permission dialog for POST_NOTIFICATIONS.
      await androidPlugin.requestNotificationsPermission();

      // SCHEDULE_EXACT_ALARM requires user approval via Special App Access on API 31+.
      final canExact =
          await androidPlugin.canScheduleExactNotifications() ?? true;
      if (!canExact) {
        // Opens Settings > Special App Access > Alarms & Reminders for this app.
        await androidPlugin.requestExactAlarmsPermission();
      }

      // Battery optimization: OEM power managers (Samsung One UI, Xiaomi MIUI,
      // etc.) can kill the BroadcastReceiver before it fires, silently dropping
      // scheduled reminders. Requesting exemption makes the app unrestricted.
      try {
        final isIgnoring = await _batteryChannel
                .invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
            true;
        if (!isIgnoring) {
          await _batteryChannel
              .invokeMethod('requestIgnoreBatteryOptimizations');
        }
      } catch (_) {}
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Cancel all existing reminders for [habit], then schedule fresh ones
  /// for every time stored in its reminders field.
  static Future<void> scheduleHabitReminders(Habit habit) async {
    await _ensureInitialized();
    await cancelHabitReminders(habit.id);

    final times = _parseTimes(habit);
    if (times.isEmpty) return;

    for (int i = 0; i < times.length; i++) {
      final parts = times[i].split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      await _scheduleDailyAt(
        id: habit.id * 100 + i,
        title: habit.name,
        body: (habit.goal != null && habit.goal!.isNotEmpty)
            ? habit.goal!
            : 'Time to complete your habit!',
        hour: hour,
        minute: minute,
      );
    }
  }

  /// Cancel all notifications belonging to [habitId].
  static Future<void> cancelHabitReminders(int habitId) async {
    if (!_initialized) return;
    for (int i = 0; i < 100; i++) {
      await _plugin.cancel(habitId * 100 + i);
    }
  }

  /// Reschedule notifications for all habits that have reminders set.
  ///
  /// Call on app startup to recover notifications lost due to events not
  /// covered by the boot receiver (battery-optimisation resets, notification
  /// channel deletion, OS notification tray clears, etc.).
  static Future<void> rescheduleAll(List<Habit> habits) async {
    await _ensureInitialized();
    for (final habit in habits) {
      if (_parseTimes(habit).isNotEmpty) {
        try {
          await scheduleHabitReminders(habit);
        } catch (_) {}
      }
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Ensures the plugin is initialized, re-running init if it previously failed.
  static Future<void> _ensureInitialized() async {
    if (!_initialized) await init();
  }

  static List<String> _parseTimes(Habit habit) {
    if (habit.reminders != null && habit.reminders!.isNotEmpty) {
      return habit.reminders!
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (habit.reminderTime != null && habit.reminderTime!.isNotEmpty) {
      return [habit.reminderTime!];
    }
    return [];
  }

  static Future<void> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time already passed today, start from tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Attempt exact alarm (requires SCHEDULE_EXACT_ALARM on Android 12+).
    // Falls back to inexact if the permission hasn't been granted — the
    // notification still fires, just potentially a few minutes late.
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
