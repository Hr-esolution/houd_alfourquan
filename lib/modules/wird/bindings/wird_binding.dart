import 'package:get/get.dart';
import '../controllers/wird_controller.dart';
import '../services/progress_service.dart';
import '../repositories/quran_repository.dart';
import '../services/wird_notification_service.dart';

/// Binding for Wird module
/// Initializes dependencies
class WirdBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy services (created when first used)
    Get.lazyPut<QuranRepository>(() => QuranRepository(), fenix: true);
    Get.lazyPut<ProgressService>(() => ProgressService(), fenix: true);
    Get.lazyPut<WirdNotificationService>(() => WirdNotificationService(), fenix: true);
    Get.lazyPut<WirdController>(() => WirdController(), fenix: true);
  }
}
