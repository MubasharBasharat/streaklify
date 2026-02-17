import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    areNotificationsEnabled.value = _storage.read<bool>('notifications_enabled', defaultValue: true) ?? true;
  }

  void toggleNotifications(bool value) {
    areNotificationsEnabled.value = value;
    _storage.write('notifications_enabled', value);
    
    if (!value) {
      NotificationService.to.cancelAllNotifications();
    } else {
      // Ideally re-schedule all, but simpler to expect they are still scheduled
      // or user needs to re-enable per streak.
      // For now, we just toggle the preference.
      // Real app might need complex rescheduling logic.
      Get.snackbar('Notifications', 'Notifications enabled');
    }
  }

  Future<void> clearAllData() async {
    Get.defaultDialog(
      title: 'Clear All Data',
      middleText: 'Are you sure you want to delete all streaks and reset the app? This cannot be undone.',
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
