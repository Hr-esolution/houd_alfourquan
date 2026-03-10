import 'package:get/get.dart';
import '../controllers/adhan_controller.dart';

class AdhanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdhanController>(() => AdhanController());
  }
}
