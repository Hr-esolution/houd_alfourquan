import 'package:get/get.dart';
import '../controllers/adhan_controller.dart';

class AdhanBinding extends Bindings {
  @override
  void dependencies() {
    // Use existing AdhanController from InitialBinding if available
    if (!Get.isRegistered<AdhanController>()) {
      Get.put<AdhanController>(AdhanController(), permanent: true);
    }
  }
}
