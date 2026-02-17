// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StreakModelAdapter extends TypeAdapter<StreakModel> {
  @override
  final int typeId = 0;

  @override
  StreakModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakModel(
      id: fields[0] as String,
      title: fields[1] as String,
      startDate: fields[2] as DateTime,
      dailyTime: fields[3] as DateTime,
      goalDays: fields[4] as int,
      currentStreak: fields[5] as int,
      longestStreak: fields[6] as int,
      completedDays: fields[7] as int,
      reminderMinutesBefore: fields[8] as int,
      isReminderEnabled: fields[9] as bool,
      strictMode: fields[10] as bool,
      lastCheckInDate: fields[11] as DateTime?,
      isCompleted: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StreakModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.dailyTime)
      ..writeByte(4)
      ..write(obj.goalDays)
      ..writeByte(5)
      ..write(obj.currentStreak)
      ..writeByte(6)
      ..write(obj.longestStreak)
      ..writeByte(7)
      ..write(obj.completedDays)
      ..writeByte(8)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(9)
      ..write(obj.isReminderEnabled)
      ..writeByte(10)
      ..write(obj.strictMode)
      ..writeByte(11)
      ..write(obj.lastCheckInDate)
      ..writeByte(12)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
