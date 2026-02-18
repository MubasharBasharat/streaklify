import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:streaklify/data/models/streak_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';

class SettingsController extends GetxController {
  final StorageService _storage = StorageService.to;

  final RxBool areNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    areNotificationsEnabled.value = _storage.read<bool>(
      'notifications_enabled',
      defaultValue: true,
    );
  }

  void toggleNotifications(bool value) async {
    if (!value) {
      // Show confirmation dialog before disabling
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Disable Notifications?'),
          content: const Text(
            'This will cancel all scheduled notifications for your streaks. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Disable',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return; // User cancelled, keep notifications on

      areNotificationsEnabled.value = false;
      await _storage.write('notifications_enabled', false);
      await NotificationService.to.cancelAllNotifications();

      Get.snackbar(
        'Notifications Disabled',
        'All reminders have been turned off.',
      );
    } else {
      areNotificationsEnabled.value = true;
      await _storage.write('notifications_enabled', true);

      // Re-schedule all active streak reminders
      final streakBox = Hive.box<StreakModel>('streaks');
      final streaks = streakBox.values.toList();

      for (final streak in streaks) {
        if (streak.isReminderEnabled && !streak.isCompleted) {
          final DateTime dailyTime = streak.dailyTime;

          DateTime scheduledTime = dailyTime.subtract(
            Duration(minutes: streak.reminderMinutesBefore),
          );

          await NotificationService.to.scheduleDailyNotification(
            id: streak.id.hashCode,
            title: 'Time for ${streak.title}!',
            body: 'Keep your streak alive! Action required.',
            hour: scheduledTime.hour,
            minute: scheduledTime.minute,
          );
        }
      }

      Get.snackbar(
        'Notifications Enabled',
        'All active streak reminders restored.',
      );
    }
  }

  void openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  void rateApp() {
    Get.snackbar('Rate App', 'Thanks for the rating! (Simulation)');
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}
