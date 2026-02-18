import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controller/progress_controller.dart';

class ProgressView extends GetView<ProgressController> {
  const ProgressView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.progress),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Obx(() => Column(
          children: [
            _buildStatGrid(),
            SizedBox(height: 24.h),
            _buildProgressList(),
          ],
        )),
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Streaks', '${controller.totalStreaks}', Colors.blue),
        _buildStatCard('Active', '${controller.activeStreaks}', Colors.green),
        _buildStatCard('Completed', '${controller.completedStreaks}', Colors.purple),
        _buildStatCard('Best Streak', '${controller.longestStreak} days', Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList() {
    if (controller.allStreaks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Streak Detail',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.allStreaks.length,
          itemBuilder: (context, index) {
            final streak = controller.allStreaks[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(streak.title, style: TextStyle(fontSize: 16.sp)),
                      Text('${(streak.progressPercentage * 100).toInt()}%'),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value: streak.progressPercentage,
                    backgroundColor: Colors.grey[800],
                    color: AppColors.primary,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
