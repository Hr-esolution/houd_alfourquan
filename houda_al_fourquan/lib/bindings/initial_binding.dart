import 'package:get/get.dart';
import '../core/services/hive_service.dart';
import '../core/services/location_service.dart';
import '../core/services/osm_service.dart';
import '../modules/home/controller/home_controller.dart';
import '../modules/prayer/services/prayer_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() async {
    // Register services as singletons (persistent throughout app lifecycle)
    Get.put(HiveService(), permanent: true);
    Get.put(LocationService(), permanent: true);
    Get.put(OSMService(), permanent: true);
    Get.put(PrayerService(), permanent: true);

    // Lazy load controller
    Get.lazyPut(() => HomeController());
  }
}
