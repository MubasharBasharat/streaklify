import 'package:get/get.dart';
import '../modules/splash/view/splash_view.dart';
import '../modules/splash/controller/splash_controller.dart';
import '../modules/home/view/home_view.dart';
import '../modules/home/controller/home_controller.dart';
import '../modules/create_streak/view/create_streak_view.dart';
import '../modules/create_streak/controller/create_streak_controller.dart';
import '../modules/progress/view/progress_view.dart';
import '../modules/progress/controller/progress_controller.dart';
import '../modules/settings/view/settings_view.dart';
import '../modules/settings/controller/settings_controller.dart';

class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const createStreak = '/create_streak';
  static const progress = '/progress';
  static const settings = '/settings';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: createStreak,
      page: () => const CreateStreakView(),
      binding: CreateStreakBinding(),
    ),
    GetPage(
      name: progress,
      page: () => const ProgressView(),
      binding: ProgressBinding(),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
