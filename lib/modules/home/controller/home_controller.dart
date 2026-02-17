import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/streak_model.dart';
import '../../../data/repositories/streak_repository.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final IStreakRepository _repository;

  HomeController({IStreakRepository? repository})
      : _repository = repository ?? StreakRepository(Hive.box<StreakModel>('streaks'));

  final RxList<StreakModel> streaks = <StreakModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStreaks();
  }

  Future<void> _loadStreaks() async {
    isLoading.value = true;
    try {
      final List<StreakModel> allStreaks = await _repository.getAllStreaks();
      
      // Strict Mode Logic: Reset streaks if missed
      final now = DateTime.now();
      for (var streak in allStreaks) {
        if (streak.strictMode && !streak.isCompleted && streak.lastCheckInDate != null) {
          final lastCheckIn = streak.lastCheckInDate!;
          // final difference = now.difference(lastCheckIn).inDays;
          
          // If check-in wasn't today or yesterday, it's a miss
          // Actually, precise logic: if lastCheckIn is before yesterday
          final yesterday = DateTime(now.year, now.month, now.day - 1);
          final lastDateOnly = DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day);
          
          if (lastDateOnly.isBefore(yesterday)) {
             streak.currentStreak = 0;
             await _repository.saveStreak(streak);
          }
        }
      }
      
      streaks.assignAll(allStreaks);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load streaks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshStreaks() {
    _loadStreaks();
  }

  Future<void> checkIn(StreakModel streak) async {
    if (streak.hasCheckedInToday) {
      Get.snackbar('Already Checked In', 'You have already checked in for today!');
      return;
    }

    try {
      streak.currentStreak++;
      streak.completedDays++;
      streak.lastCheckInDate = DateTime.now();

      if (streak.currentStreak > streak.longestStreak) {
        streak.longestStreak = streak.currentStreak;
      }

      if (streak.completedDays >= streak.goalDays) {
        streak.isCompleted = true;
        Get.snackbar('Congratulations!', 'You have reached your goal for ${streak.title}!');
      }

      await _repository.saveStreak(streak);
      
      // Cancel today's notification
      // Note: This requires mapping notifications which we haven't strictly done, 
      // but we can assume ID based handling or implementation specific.
      // For now, let's just save.
      
      // Update local list
      final index = streaks.indexWhere((s) => s.id == streak.id);
      if (index != -1) {
        streaks[index] = streak;
      }
      update(); // Force UI update if needed, though Obx handles it
      
      Get.snackbar('Success', 'Streak updated! Keep it up!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to check in: $e');
    }
  }
  
  void navigateToCreateStreak() async {
    final result = await Get.toNamed(AppRoutes.createStreak);
    if (result == true) {
      _loadStreaks();
    }
  }

  Future<void> deleteStreak(StreakModel streak) async {
    try {
      await _repository.deleteStreak(streak.id);
      streaks.remove(streak);
      
      // Cancel notification
      // We need an int ID for notifications. We can hash the UUID string
      await NotificationService.to.cancelNotification(streak.id.hashCode);
      
      Get.snackbar('Deleted', 'Streak deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete streak');
    }
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
