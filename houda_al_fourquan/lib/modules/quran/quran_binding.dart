import 'package:get/get.dart';
import 'controllers/reciter_controller.dart';
import 'controllers/quran_controller.dart';

class QuranBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load controllers
    Get.lazyPut<QuranController>(() => QuranController(), fenix: true);
    Get.lazyPut<ReciterController>(() => ReciterController(), fenix: true);
    // PlayerController is created on demand in the view
  }
}
