import 'package:get/get.dart';
import 'tasbih_controller.dart';

class TasbihBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TasbihController());
  }
}
