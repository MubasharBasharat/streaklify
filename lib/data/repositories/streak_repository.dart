import 'package:hive_flutter/hive_flutter.dart';
import '../models/streak_model.dart';

abstract class IStreakRepository {
  Future<List<StreakModel>> getAllStreaks();
  Future<void> saveStreak(StreakModel streak);
  Future<void> deleteStreak(String id);
  Future<void> updateStreak(StreakModel streak);
}

class StreakRepository implements IStreakRepository {
  final Box<StreakModel> _box;

  StreakRepository(this._box);

  @override
  Future<List<StreakModel>> getAllStreaks() async {
    return _box.values.toList();
  }

  @override
  Future<void> saveStreak(StreakModel streak) async {
    await _box.put(streak.id, streak);
  }

  @override
  Future<void> deleteStreak(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> updateStreak(StreakModel streak) async {
    await _box.put(streak.id, streak);
  }
}
