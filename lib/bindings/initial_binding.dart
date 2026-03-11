import 'package:get/get.dart';
import '../core/services/hive_service.dart';
import '../core/services/location_service.dart';
import '../core/services/osm_service.dart';
import '../modules/home/controller/home_controller.dart';
import '../modules/prayer/services/prayer_service.dart';
import '../modules/prayer/services/adhan_notification_service.dart';
import '../modules/prayer/controllers/adhan_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() async {
    // Register services as singletons (persistent throughout app lifecycle)
    Get.put(HiveService(), permanent: true);
    Get.put(LocationService(), permanent: true);
    Get.put(OSMService(), permanent: true);
    Get.put(PrayerService(), permanent: true);
    
    // Initialize Adhan services
    Get.put(AdhanController(), permanent: true);
    Get.put(AdhanNotificationService(), permanent: true);
    
    // Initialize Adhan notifications
    final adhanService = Get.find<AdhanNotificationService>();
    await adhanService.init();

    // Lazy load controller
    Get.lazyPut(() => HomeController());
  }
}
