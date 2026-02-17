import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/streak_model.dart';
import '../../../data/repositories/streak_repository.dart';

class CreateStreakController extends GetxController {
  final IStreakRepository _repository;

  CreateStreakController({IStreakRepository? repository})
      : _repository = repository ?? StreakRepository(Hive.box<StreakModel>('streaks'));

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
    if (!formKey.currentState!.validate()) return;

    try {
      final DateTime timeDate = DateTime(
        startDate.value.year,
        startDate.value.month,
        startDate.value.day,
        dailyTime.value.hour,
        dailyTime.value.minute,
      );

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

      if (isReminderEnabled.value) {
        // Calculate notification time
        // Notification time = dailyTime - reminderMinutesBefore
        // We handle this schedule logic here or in service.
        // Let's calculate the target hour/min
        
        DateTime scheduledTime = timeDate.subtract(Duration(minutes: reminderMinutesBefore.value));
        
        await NotificationService.to.scheduleDailyNotification(
          id: newStreak.id.hashCode,
          title: 'Time for ${newStreak.title}!',
          body: 'Keep your streak alive! Action required.',
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
        );
      }

      Get.back(result: true);
      Get.snackbar('Success', 'Streak created successfully!');
    } catch (e) {
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
