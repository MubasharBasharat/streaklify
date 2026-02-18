import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../controller/home_controller.dart';
import 'widgets/streak_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myStreaks),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.streaks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 64.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppStrings.noStreaks,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.streaks.length,
          itemBuilder: (context, index) {
            final streak = controller.streaks[index];
            return StreakCard(
              streak: streak,
              onCheckIn: () => controller.checkIn(streak),
              onDelete: () => controller.deleteStreak(streak),
              onEdit: () => controller.navigateToEditStreak(streak),
            );
          },
        );
      }),
    );
  }
}

