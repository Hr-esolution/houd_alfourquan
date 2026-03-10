import 'package:get/get.dart';
import '../controllers/tasbih_controller.dart';

/// Tasbih Binding
class TasbihBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TasbihController>(() => TasbihController());
  }
}
