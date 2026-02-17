import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'streak_model.g.dart';

@HiveType(typeId: 0)
class StreakModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime dailyTime; // Stores time component

  @HiveField(4)
  final int goalDays;

  @HiveField(5)
  int currentStreak;

  @HiveField(6)
  int longestStreak;

  @HiveField(7)
  int completedDays;

  @HiveField(8)
  final int reminderMinutesBefore;

  @HiveField(9)
  final bool isReminderEnabled;

  @HiveField(10)
  final bool strictMode; // Reset on miss

  @HiveField(11)
  DateTime? lastCheckInDate;

  @HiveField(12)
  bool isCompleted;

  StreakModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.dailyTime,
    required this.goalDays,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedDays = 0,
    required this.reminderMinutesBefore,
    required this.isReminderEnabled,
    this.strictMode = false,
    this.lastCheckInDate,
    this.isCompleted = false,
  });

  factory StreakModel.create({
    required String title,
    required DateTime startDate,
    required DateTime dailyTime,
    required int goalDays,
    required int reminderMinutesBefore,
    required bool isReminderEnabled,
    required bool strictMode,
  }) {
    return StreakModel(
      id: const Uuid().v4(),
      title: title,
      startDate: startDate,
      dailyTime: dailyTime,
      goalDays: goalDays,
      reminderMinutesBefore: reminderMinutesBefore,
      isReminderEnabled: isReminderEnabled,
      strictMode: strictMode,
    );
  }
  
  // Computed Properties
  double get progressPercentage {
    if (goalDays == 0) return 0.0;
    return (currentStreak / goalDays).clamp(0.0, 1.0);
  }

  int get remainingDays {
    return (goalDays - completedDays).clamp(0, goalDays);
  }

  // Check if checked in today
  bool get hasCheckedInToday {
    if (lastCheckInDate == null) return false;
    final now = DateTime.now();
    return lastCheckInDate!.year == now.year &&
           lastCheckInDate!.month == now.month &&
           lastCheckInDate!.day == now.day;
  }
}
