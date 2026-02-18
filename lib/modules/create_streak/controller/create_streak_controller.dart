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
  final RxInt reminderMinutesBefore = 15.obs;
  final RxBool isEditMode = false.obs;
  final RxBool globalNotificationsEnabled = true.obs;

  final List<int> reminderOptions = [0, 15, 30, 60];

  // Holds existing streak when editing
  StreakModel? _existingStreak;

  @override
  void onInit() {
    super.onInit();
    _loadGlobalNotificationStatus();

    // Check if an existing streak was passed for editing
    final args = Get.arguments;
    if (args != null && args is StreakModel) {
      _existingStreak = args;
      isEditMode.value = true;
      _prefillForm(args);
    }
  }

  void _loadGlobalNotificationStatus() {
    globalNotificationsEnabled.value = StorageService.to.read<bool>(
      'notifications_enabled',
      defaultValue: true,
    );
  }

  void _prefillForm(StreakModel streak) {
    titleController.text = streak.title;
    goalDaysController.text = streak.goalDays.toString();
    startDate.value = streak.startDate;
    dailyTime.value = TimeOfDay(
      hour: streak.dailyTime.hour,
      minute: streak.dailyTime.minute,
    );
    strictMode.value = streak.strictMode;
    isReminderEnabled.value = streak.isReminderEnabled;
    reminderMinutesBefore.value = streak.reminderMinutesBefore;
  }

  /// Called when user toggles the reminder switch.
  /// If global notifications are off, revert and inform the user.
  void onReminderToggled(bool val) {
    if (val && !globalNotificationsEnabled.value) {
      isReminderEnabled.value = false;
      return;
    }
    isReminderEnabled.value = val;
  }

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

      if (isEditMode.value && _existingStreak != null) {
        await _updateExistingStreak(timeDate);
      } else {
        await _createNewStreak(timeDate);
      }
    } catch (e, stack) {
      debugPrint("$tag ❌ ERROR: $e");
      debugPrint("$tag ❌ STACK: $stack");
      Get.snackbar('Error', 'Failed to save streak: $e');
    }
  }

  Future<void> _createNewStreak(DateTime timeDate) async {
    final newStreak = StreakModel.create(
      title: titleController.text.trim(),
      startDate: startDate.value,
      dailyTime: timeDate,
      goalDays: int.parse(goalDaysController.text),
      reminderMinutesBefore: reminderMinutesBefore.value,
      isReminderEnabled: isReminderEnabled.value,
      strictMode: strictMode.value,
    );

    await _repository.saveStreak(newStreak);

    if (isReminderEnabled.value && globalNotificationsEnabled.value) {
      await _scheduleNotification(newStreak.id, newStreak.title, timeDate);
    }

    Get.back(result: true);
    Get.snackbar('Success', 'Streak created successfully!');
  }

  Future<void> _updateExistingStreak(DateTime timeDate) async {
    final streak = _existingStreak!;

    // Cancel the old notification
    await NotificationService.to.cancelNotification(streak.id.hashCode);

    // Create an updated model preserving progress data
    final updatedStreak = StreakModel(
      id: streak.id,
      title: titleController.text.trim(),
      startDate: startDate.value,
      dailyTime: timeDate,
      goalDays: int.parse(goalDaysController.text),
      reminderMinutesBefore: reminderMinutesBefore.value,
      isReminderEnabled: isReminderEnabled.value,
      strictMode: strictMode.value,
      // Preserve existing progress
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      completedDays: streak.completedDays,
      lastCheckInDate: streak.lastCheckInDate,
      isCompleted: streak.isCompleted,
    );

    await _repository.updateStreak(updatedStreak);

    if (isReminderEnabled.value && globalNotificationsEnabled.value) {
      await _scheduleNotification(updatedStreak.id, updatedStreak.title, timeDate);
    }

    Get.back(result: true);
    Get.snackbar('Success', 'Streak updated successfully!');
  }

  Future<void> _scheduleNotification(
    String streakId,
    String title,
    DateTime timeDate,
  ) async {
    DateTime scheduledTime = timeDate.subtract(
      Duration(minutes: reminderMinutesBefore.value),
    );

    await NotificationService.to.scheduleDailyNotification(
      id: streakId.hashCode,
      title: 'Time for $title!',
      body: 'Keep your streak alive! Action required.',
      hour: scheduledTime.hour,
      minute: scheduledTime.minute,
    );
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
