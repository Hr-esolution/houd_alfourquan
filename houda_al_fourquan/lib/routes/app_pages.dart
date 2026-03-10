import 'package:get/get.dart';
import '../modules/splash/splash_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/qibla/qibla_view.dart';
import '../modules/qibla/qibla_binding.dart';
import '../modules/tasbih/tasbih_view.dart';
import '../modules/tasbih/tasbih_binding.dart';
import '../modules/quran/quran_view.dart';
import '../modules/quran/quran_binding.dart';
import '../modules/quran/views/surah_reading_page.dart';
import '../modules/prayer/views/prayer_view.dart';
import '../modules/prayer/bindings/prayer_binding.dart';
import '../modules/prayer/views/adhan_settings_page.dart';
import '../modules/prayer/bindings/adhan_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/legal/views/privacy_policy_view.dart';
import '../modules/legal/views/terms_of_service_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.splash, page: () => SplashView()),

    GetPage(name: Routes.home, page: () => HomeView()),

    GetPage(
      name: Routes.qibla,
      page: () => const QiblaView(),
      binding: QiblaBinding(),
    ),

    GetPage(
      name: Routes.tasbih,
      page: () => TasbihView(),
      binding: TasbihBinding(),
    ),

    GetPage(
      name: Routes.quran,
      page: () => QuranView(),
      binding: QuranBinding(),
    ),

    GetPage(name: Routes.surahReading, page: () => const SurahReadingPage()),

    GetPage(
      name: Routes.prayer,
      page: () => PrayerView(),
      binding: PrayerBinding(),
    ),

    GetPage(
      name: Routes.adhanSettings,
      page: () => const AdhanSettingsPage(),
      binding: AdhanBinding(),
    ),

    GetPage(name: Routes.settings, page: () => SettingsView()),

    GetPage(
      name: Routes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),

    GetPage(
      name: Routes.termsOfService,
      page: () => const TermsOfServiceView(),
    ),
  ];
}
