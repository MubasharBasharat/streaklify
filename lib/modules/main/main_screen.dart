import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../home/controller/home_controller.dart';
import '../home/view/home_view.dart';
import '../progress/controller/progress_controller.dart';
import '../progress/view/progress_view.dart';
import '../settings/controller/settings_controller.dart';
import '../settings/view/settings_view.dart';
import 'main_controller.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Eagerly initialize tab controllers so they persist across tab switches
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ProgressController());
    Get.lazyPut(() => SettingsController());

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              ProgressView(),
              SettingsView(),
            ],
          ),
          floatingActionButton: controller.currentIndex.value == 0
              ? FloatingActionButton(
                  onPressed: () async {
                    final result = await Get.toNamed(AppRoutes.createStreak);
                    if (result == true) {
                      Get.find<HomeController>().refreshStreaks();
                    }
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            backgroundColor: AppColors.surface,
            onTap: controller.changePage,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ));
  }
}
