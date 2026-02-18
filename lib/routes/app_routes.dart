import 'package:get/get.dart';
import '../modules/splash/view/splash_view.dart';
import '../modules/splash/controller/splash_controller.dart';
import '../modules/main/main_screen.dart';
import '../modules/main/main_controller.dart';
import '../modules/create_streak/view/create_streak_view.dart';
import '../modules/create_streak/controller/create_streak_controller.dart';

class AppRoutes {
  static const splash = '/splash';
  static const main = '/main';
  static const createStreak = '/create_streak';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: main,
      page: () => const MainScreen(),
      binding: MainBinding(),
    ),
    GetPage(
      name: createStreak,
      page: () => const CreateStreakView(),
      binding: CreateStreakBinding(),
    ),
  ];
}
