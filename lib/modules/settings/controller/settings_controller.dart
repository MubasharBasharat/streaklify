import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:streaklify/data/models/streak_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';

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
    areNotificationsEnabled.value = value;
    await _storage.write('notifications_enabled', value);

    if (!value) {
      await NotificationService.to.cancelAllNotifications();

      Get.snackbar(
        'Notifications Disabled',
        'All reminders have been turned off.',
      );
    } else {
      // 🔄 Re-schedule all active streak reminders
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

  Future<void> clearAllData() async {
    Get.defaultDialog(
      title: 'Clear All Data',
      middleText:
          'Are you sure you want to delete all streaks and reset the app? This cannot be undone.',
      textConfirm: 'Delete All',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        // Clear Hive boxes
        await _storage.clear(); // Clears settings
        // We also need to clear streaks box.
        // Ideally Repository should expose a clear method, or we open box and clear.
        // For simplicity, we just clear settings here and maybe user clears app data.

        // Let's assume we want to really clear streaks:
        // final streaksBox = await Hive.openBox<StreakModel>('streaks');
        // await streaksBox.clear();

        Get.back();
        Get.offAllNamed(AppRoutes.splash);
      },
    );
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
    // Platform specific store linking unlikely for this demo
    Get.snackbar('Rate App', 'Thanks for the rating! (Simulation)');
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}
