import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/streak_model.dart';
import '../../../data/repositories/streak_repository.dart';

class ProgressController extends GetxController {
  final IStreakRepository _repository;

  ProgressController({IStreakRepository? repository})
      : _repository = repository ?? StreakRepository(Hive.box<StreakModel>('streaks'));

  final RxInt totalStreaks = 0.obs;
  final RxInt activeStreaks = 0.obs;
  final RxInt completedStreaks = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxList<StreakModel> allStreaks = <StreakModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadStats();
  }

  void refreshStats() {
    _loadStats();
  }

  Future<void> _loadStats() async {
    final streaks = await _repository.getAllStreaks();
    allStreaks.assignAll(streaks);
    
    totalStreaks.value = streaks.length;
    completedStreaks.value = streaks.where((s) => s.isCompleted).length;
    activeStreaks.value = streaks.where((s) => !s.isCompleted).length;
    
    if (streaks.isNotEmpty) {
      longestStreak.value = streaks
          .map((s) => s.longestStreak)
          .reduce((curr, next) => curr > next ? curr : next);
    } else {
      longestStreak.value = 0;
    }
  }
}

class ProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProgressController());
  }
}
