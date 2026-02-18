import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:streaklify/core/services/storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/streak_model.dart';
import '../../../data/repositories/streak_repository.dart';

class CreateStreakController extends GetxController {
  final IStreakRepository _repository;

  CreateStreakController({IStreakRepository? repository})
    : _repository =
          repository ?? StreakRepository(Hive.box<StreakModel>('streaks'));

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController goalDaysController = TextEditingController();

  // Observables
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<TimeOfDay> dailyTime = const TimeOfDay(hour: 9, minute: 0).obs;
  final RxBool strictMode = false.obs;
  final RxBool isReminderEnabled = true.obs;
  final RxInt reminderMinutesBefore = 15.obs; // 15, 30, 60

  final List<int> reminderOptions = [0, 15, 30, 60];

  Future<void> saveStreak() async {
    const tag = "[CreateStreakController.saveStreak]";

    debugPrint("$tag 🔹 ENTERED FUNCTION");

    if (!formKey.currentState!.validate()) {
      debugPrint("$tag ❌ Form validation failed");
      return;
    }

    debugPrint("$tag ✅ Form validated");

    try {
      final DateTime timeDate = DateTime(
        startDate.value.year,
        startDate.value.month,
        startDate.value.day,
        dailyTime.value.hour,
        dailyTime.value.minute,
      );

      debugPrint("$tag 🕒 timeDate = $timeDate");

      final newStreak = StreakModel.create(
        title: titleController.text.trim(),
        startDate: startDate.value,
        dailyTime: timeDate,
        goalDays: int.parse(goalDaysController.text),
        reminderMinutesBefore: reminderMinutesBefore.value,
        isReminderEnabled: isReminderEnabled.value,
        strictMode: strictMode.value,
      );

      debugPrint("$tag 🆕 Streak created with ID = ${newStreak.id}");

      debugPrint("$tag 💾 Saving streak to repository...");
      await _repository.saveStreak(newStreak);
      debugPrint("$tag ✅ Repository save complete");

      final bool globalNotificationsEnabled =
          StorageService.to.read<bool>(
            'notifications_enabled',
            defaultValue: true,
          ) ??
          true;

      debugPrint(
        "$tag 🔔 ReminderEnabled=${isReminderEnabled.value}, "
        "GlobalEnabled=$globalNotificationsEnabled",
      );

      if (isReminderEnabled.value && globalNotificationsEnabled) {
        DateTime scheduledTime = timeDate.subtract(
          Duration(minutes: reminderMinutesBefore.value),
        );

        final now = DateTime.now();

        debugPrint(
          "$tag 🕒 Scheduling '${newStreak.title}' "
          "at ${scheduledTime.hour}:${scheduledTime.minute} "
          "(Now: ${now.hour}:${now.minute}) "
          "ID=${newStreak.id.hashCode}",
        );

        await NotificationService.to.scheduleDailyNotification(
          id: newStreak.id.hashCode,
          title: 'Time for ${newStreak.title}!',
          body: 'Keep your streak alive! Action required.',
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
        );

        debugPrint("$tag ✅ Notification scheduled");
      } else {
        debugPrint("$tag 🚫 Notification NOT scheduled");
      }

      debugPrint("$tag 🔙 Navigating back...");
      Get.back(result: true);

      debugPrint("$tag 🎉 Showing success snackbar");
      Get.snackbar('Success', 'Streak created successfully!');
    } catch (e, stack) {
      debugPrint("$tag ❌ ERROR: $e");
      debugPrint("$tag ❌ STACK: $stack");
      Get.snackbar('Error', 'Failed to create streak: $e');
    }
  }

  void updateStartDate(DateTime date) {
    startDate.value = date;
  }

  void updateDailyTime(TimeOfDay time) {
    dailyTime.value = time;
  }

  @override
  void onClose() {
    titleController.dispose();
    goalDaysController.dispose();
    super.onClose();
  }
}

class CreateStreakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateStreakController());
  }
}
