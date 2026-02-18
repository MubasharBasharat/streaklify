import 'package:get/get.dart';
import '../progress/controller/progress_controller.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;

    // Refresh Progress stats when switching to Progress tab
    if (index == 1) {
      try {
        final progressCtrl = Get.find<ProgressController>();
        progressCtrl.refreshStats();
      } catch (_) {}
    }
  }
}

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
  }
}
