import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../modules/main/main_controller.dart';
import '../controller/create_streak_controller.dart';

class CreateStreakView extends GetView<CreateStreakController> {
  const CreateStreakView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditMode.value
                  ? 'Edit Streak'
                  : AppStrings.createStreak,
            )),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(AppStrings.streakName),
              SizedBox(height: 8.h),
              TextFormField(
                controller: controller.titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Read 30 mins',
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.errorRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              _buildLabel(AppStrings.goalDays),
              SizedBox(height: 8.h),
              TextFormField(
                controller: controller.goalDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g., 30',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.errorRequired;
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              _buildLabel('Start Date'),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.startDate.value,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: AppColors.surface,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    controller.updateStartDate(picked);
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.white70),
                      SizedBox(width: 12.w),
                      Obx(() => Text(
                            DateFormat.yMMMd()
                                .format(controller.startDate.value),
                            style: TextStyle(fontSize: 16.sp),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _buildLabel(AppStrings.dailyTime),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: controller.dailyTime.value,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: AppColors.surface,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    controller.updateDailyTime(picked);
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white70),
                      SizedBox(width: 12.w),
                      Obx(() => Text(
                            controller.dailyTime.value.format(context),
                            style: TextStyle(fontSize: 16.sp),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // ── Enable Reminders Toggle ──
              Obx(() => SwitchListTile(
                    title: const Text('Enable Reminders'),
                    value: controller.isReminderEnabled.value,
                    onChanged: controller.onReminderToggled,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  )),

              // ── Notification Guard: show warning if global notifications are off ──
              Obx(() {
                if (!controller.globalNotificationsEnabled.value) {
                  return Container(
                    margin: EdgeInsets.only(top: 8.h, bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Notifications are disabled in Settings. Enable them to schedule reminders.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        TextButton(
                          onPressed: () {
                            Get.back(); // Close create/edit screen
                            // Switch to Settings tab (index 2)
                            try {
                              final mainCtrl = Get.find<MainController>();
                              mainCtrl.changePage(2);
                            } catch (_) {}
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                          ),
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // ── Reminder Options (only if enabled) ──
              Obx(() {
                if (!controller.isReminderEnabled.value) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    const Text('Remind me before:'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<int>(
                      value: controller.reminderMinutesBefore.value,
                      items: controller.reminderOptions.map((int val) {
                        return DropdownMenuItem<int>(
                          value: val,
                          child: Text(val == 0
                              ? 'At time of event'
                              : '$val minutes before'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.reminderMinutesBefore.value = val;
                        }
                      },
                      dropdownColor: AppColors.surface,
                    ),
                  ],
                );
              }),

              SizedBox(height: 20.h),
              Obx(() => SwitchListTile(
                    title: const Text(AppStrings.strictMode),
                    subtitle: Text(
                      AppStrings.strictModeDesc,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    value: controller.strictMode.value,
                    onChanged: (val) => controller.strictMode.value = val,
                    activeColor: AppColors.error,
                    contentPadding: EdgeInsets.zero,
                  )),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.saveStreak,
                      child: Text(controller.isEditMode.value
                          ? 'Update Streak'
                          : 'Save Streak'),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
      ),
    );
  }
}
