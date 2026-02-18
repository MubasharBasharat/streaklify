import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controller/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSectionHeader('Preferences'),
          Obx(
            () => SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive daily reminders for your streaks'),
              value: controller.areNotificationsEnabled.value,
              onChanged: controller.toggleNotifications,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(),
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () => controller.openUrl('https://example.com/privacy'),
          ),
          ListTile(
            title: const Text('Send Feedback'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () => controller.openUrl('mailto:support@streaklify.com'),
          ),

          SizedBox(height: 20.h),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
