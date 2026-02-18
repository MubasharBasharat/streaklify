import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/streak_model.dart';

class StreakCard extends StatelessWidget {
  final StreakModel streak;
  final VoidCallback onCheckIn;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const StreakCard({
    Key? key,
    required this.streak,
    required this.onCheckIn,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(streak.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        color: AppColors.error,
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      confirmDismiss: (direction) => _confirmDelete(),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Title + Fire Badge + Delete ──
            // ── Top Row: Title + Fire Badge + Edit + Delete ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streak.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${streak.remainingDays} days remaining',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildFireBadge(),
                SizedBox(width: 8.w),

                // ✏️ EDIT ICON
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.edit_outlined,
                      color: AppColors.secondary,
                      size: 20.sp,
                    ),
                  ),
                ),

                SizedBox(width: 6.w),

                // 🗑 DELETE ICON
                InkWell(
                  onTap: () async {
                    final confirmed = await _confirmDelete();
                    if (confirmed == true) onDelete();
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.error.withOpacity(0.8),
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // ── Notification Info Row ──
            Row(
              children: [
                Icon(
                  streak.isReminderEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off_outlined,
                  color: streak.isReminderEnabled
                      ? AppColors.secondary
                      : Colors.grey,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  streak.isReminderEnabled
                      ? _formatNotificationTime()
                      : 'Reminders off',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: streak.isReminderEnabled
                        ? AppColors.secondary
                        : Colors.grey,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // ── Progress Row ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress: ${(streak.progressPercentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: streak.progressPercentage,
                          backgroundColor: Colors.grey[800],
                          color: AppColors.secondary,
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                if (!streak.isCompleted)
                  ElevatedButton(
                    onPressed: streak.hasCheckedInToday ? null : onCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: streak.hasCheckedInToday
                          ? Colors.grey
                          : AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      streak.hasCheckedInToday ? 'Done' : 'Check-in',
                      style: GoogleFonts.poppins(fontSize: 12.sp),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNotificationTime() {
    final dt = streak.dailyTime;
    final adjustedDt = dt.subtract(
      Duration(minutes: streak.reminderMinutesBefore),
    );
    final formatted = DateFormat.jm().format(adjustedDt);
    return 'Daily at $formatted';
  }

  Future<bool?> _confirmDelete() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Streak'),
        content: const Text('Are you sure you want to delete this streak?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFireBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            '${streak.currentStreak}',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
