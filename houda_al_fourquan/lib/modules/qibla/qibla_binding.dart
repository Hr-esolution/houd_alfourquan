import 'package:get/get.dart';
import 'qibla_controller.dart';

class QiblaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QiblaController>(() => QiblaController());
    // LocationService est déjà injecté globalement — pas besoin de réinjecter
  }
}
