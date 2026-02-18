import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    const logTag = "[NotificationService]";

    tz_data.initializeTimeZones();
    debugPrint("$logTag 🕒 Timezone initialized: ${tz.local.name}");

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // ✅ FIXED (named parameter required)
    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestPermissions();

    debugPrint("$logTag ✅ Initialized successfully");

    return this;
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final data = jsonDecode(response.payload!);
      debugPrint("[NotificationService] 🔔 Tap → $data");
    } catch (_) {
      debugPrint("[NotificationService] ⚠️ Invalid payload");
    }
  }

  // ============================================================
  // ✅ DAILY REPEATING NOTIFICATION
  // ============================================================

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await cancelNotification(id);

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      'streak_reminders',
      'Streak Reminders',
      channelDescription: 'Daily reminders for streak tasks',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    debugPrint(
      "[NotificationService] 📅 Scheduled DAILY at $hour:$minute (ID: $id)",
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // ============================================================
  // ✅ IMMEDIATE NOTIFICATION
  // ============================================================

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'General notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // ✅ FIXED (named parameters required)
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  Future<void> scheduleTestNotification() async {
    final now = tz.TZDateTime.now(tz.local);

    final scheduledTime = now.add(const Duration(seconds: 10));

    await _plugin.zonedSchedule(
      id: 999,
      title: "Scheduled Test",
      body: "This should appear in 10 seconds ⏰",
      scheduledDate: scheduledTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          channelDescription: 'General notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: null,
    );
  }

  // ============================================================
  // ✅ CANCEL METHODS
  // ============================================================

  Future<void> cancelNotification(int id) async {
    // ✅ FIXED (named parameter required)
    await _plugin.cancel(id: id);
    debugPrint("[NotificationService] ❌ Canceled ID: $id");
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint("[NotificationService] 🧹 All notifications canceled");
  }
}
