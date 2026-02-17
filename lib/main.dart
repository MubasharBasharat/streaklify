import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/models/streak_model.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(StreakModelAdapter());

  // Init Services
  await Get.putAsync(() => StorageService().init());
  // await Get.putAsync(() => NotificationService().init());
  await Get.putAsync(() => NotificationService().init());

  runApp(const StreaklifyApp());
}

class StreaklifyApp extends StatelessWidget {
  const StreaklifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Mobile base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Streaklify',
          theme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.routes,
          defaultTransition: Transition.fade,
        );
      },
    );
  }
}
