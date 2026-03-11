import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:houda_al_fourquan/bindings/initial_binding.dart';
import 'package:houda_al_fourquan/core/controllers/language_controller.dart';
import 'package:houda_al_fourquan/core/controllers/theme_controller.dart';
import 'package:houda_al_fourquan/core/services/storage_service.dart';
import 'package:houda_al_fourquan/routes/app_pages.dart';
import 'package:houda_al_fourquan/routes/app_routes.dart';

import 'core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Hive storage
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize StorageService first (required by ThemeController)
  final storageService = Get.put(StorageService(), permanent: true);
  await storageService.init();

  // Initialize Language Controller
  Get.put(LanguageController());

  // Initialize Theme Controller
  final themeController = Get.put(ThemeController(), permanent: true);

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final LanguageController langController = Get.find<LanguageController>();

    // Dark theme
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFC9A84C),
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF181818),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFC9A84C)),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
        bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      ),
    );

    // Light theme
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1B5E20),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF0A0A0A)),
        bodyMedium: TextStyle(color: Color(0xFF0A0A0A)),
      ),
    );

    return GetBuilder<ThemeController>(
      init: themeController,
      builder: (controller) {
        return GetBuilder<LanguageController>(
          init: langController,
          builder: (langCtrl) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: "Houda Al Fourquan",
              initialBinding: InitialBinding(),
              initialRoute: Routes.splash,
              getPages: AppPages.routes,
              translations: _AppTranslations(),
              locale: Locale(langCtrl.currentLang),
              fallbackLocale: const Locale('fr'),
              supportedLocales: const [
                Locale('fr'),
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: controller.isDarkMode.value
                  ? ThemeMode.dark
                  : ThemeMode.light,
              defaultTransition: Transition.fade,
            );
          },
        );
      },
    );
  }
}

class _AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'houda_al_fourquan': {
      'fr': 'Houda Al Fourquan',
      'en': 'Houda Al Fourquan',
      'ar': 'Houda Al Fourquan',
    },
    'Heures de prière': {
      'fr': 'Heures de prière',
      'en': 'Prayer Times',
      'ar': 'أوقات الصلاة',
    },
    'Accueil': {'fr': 'Accueil', 'en': 'Home', 'ar': 'الرئيسية'},
    'Qibla': {'fr': 'Qibla', 'en': 'Qibla', 'ar': 'القبلة'},
    'Tasbih': {'fr': 'Tasbih', 'en': 'Tasbih', 'ar': 'التسبيح'},
    'Coran': {'fr': 'Coran', 'en': 'Quran', 'ar': 'القرآن'},
    'Paramètres': {'fr': 'Paramètres', 'en': 'Settings', 'ar': 'الإعدادات'},
    'Saint Coran': {
      'fr': 'Saint Coran',
      'en': 'Holy Quran',
      'ar': 'القرآن الكريم',
    },
    'Choisir le récitateurs': {
      'fr': 'Choisir le récitateurs',
      'en': 'Select Reciter',
      'ar': 'اختر القارئ',
    },
    'Télécharger les sourates': {
      'fr': 'Télécharger les sourates',
      'en': 'Download Surahs',
      'ar': 'تحميل السور',
    },
    'Toutes les sourates': {
      'fr': 'Toutes les sourates',
      'en': 'All Surahs',
      'ar': 'جميع السور',
    },
    'sourates téléchargées': {
      'fr': 'sourates téléchargées',
      'en': 'surahs downloaded',
      'ar': 'السور المحملة',
    },
    'En lecture': {
      'fr': 'En lecture',
      'en': 'Now playing',
      'ar': 'جاري التشغيل',
    },
    'Télécharger pour écoute hors ligne': {
      'fr': 'Télécharger pour écoute hors ligne',
      'en': 'Download for offline',
      'ar': 'تحميل للاستماع بدون إنترنت',
    },
    'Tout télécharger': {
      'fr': 'Tout télécharger',
      'en': 'Download All',
      'ar': 'تحميل الكل',
    },
    'Téléchargé': {'fr': 'Téléchargé', 'en': 'Downloaded', 'ar': 'تم التحميل'},
    'Supprimer': {'fr': 'Supprimer', 'en': 'Delete', 'ar': 'حذف'},
    'Télécharger': {'fr': 'Télécharger', 'en': 'Download', 'ar': 'تحميل'},
    'utilisé': {'fr': 'utilisé', 'en': 'used', 'ar': 'مستخدم'},
    'Sélectionné': {'fr': 'Sélectionné', 'en': 'Selected', 'ar': 'محدد'},
    'Actualiser': {'fr': 'Actualiser', 'en': 'Refresh', 'ar': 'تحديث'},
    'Réinitialiser le cache': {
      'fr': 'Réinitialiser le cache',
      'en': 'Reset Cache',
      'ar': 'إعادة تعيين الذاكرة',
    },
    'Annuler': {'fr': 'Annuler', 'en': 'Cancel', 'ar': 'إلغاء'},
    'Terminé': {'fr': 'Terminé', 'en': 'Complete', 'ar': 'اكتمل'},
    'Succès': {'fr': 'Succès', 'en': 'Success', 'ar': 'نجاح'},
    'Erreur': {'fr': 'Erreur', 'en': 'Error', 'ar': 'خطأ'},
    'Langue': {'fr': 'Langue', 'en': 'Language', 'ar': 'اللغة'},
    'Mode sombre': {
      'fr': 'Mode sombre',
      'en': 'Dark Mode',
      'ar': 'الوضع الداكن',
    },
    'Notifications': {
      'fr': 'Notifications',
      'en': 'Notifications',
      'ar': 'الإشعارات',
    },
    'À propos': {'fr': 'À propos', 'en': 'About', 'ar': 'حول'},
    'Chargement': {'fr': 'Chargement', 'en': 'Loading', 'ar': 'جاري التحميل'},
    'Veuillez d\'abord choisir un récitateurs': {
      'fr': 'Veuillez d\'abord choisir un récitateurs',
      'en': 'Please select a reciter first',
      'ar': 'الرجاء اختيار القارئ أولاً',
    },
    'Pas de connexion': {
      'fr': 'Pas de connexion',
      'en': 'No Connection',
      'ar': 'لا يوجد اتصال',
    },
    'Permission refusée': {
      'fr': 'Permission refusée',
      'en': 'Permission Denied',
      'ar': 'تم رفض الإذن',
    },
    'Prière': {'fr': 'Prière', 'en': 'Prayer', 'ar': 'الصلاة'},
    'Direction': {'fr': 'Direction', 'en': 'Direction', 'ar': 'الاتجاه'},
    'Dhikr': {'fr': 'Dhikr', 'en': 'Dhikr', 'ar': 'الذكر'},
    'Écouter': {'fr': 'Écouter', 'en': 'Listen', 'ar': 'استماع'},
    'Réglages': {'fr': 'Réglages', 'en': 'Settings', 'ar': 'الإعدادات'},
    'Accès rapide': {
      'fr': 'Accès rapide',
      'en': 'Quick Access',
      'ar': 'الوصول السريع',
    },

    // ═══════════════════════════════════════════════════════════════
    //  LEGAL PAGES - PRIVACY POLICY & TERMS OF SERVICE
    // ═══════════════════════════════════════════════════════════════
    'Politique de Confidentialité': {
      'fr': 'Politique de Confidentialité',
      'en': 'Privacy Policy',
      'ar': 'سياسة الخصوصية',
    },
    'Terms of Service': {
      'fr': 'Conditions d\'utilisation',
      'en': 'Terms of Service',
      'ar': 'شروط الخدمة',
    },
    'View terms and conditions': {
      'fr': 'Voir les termes et conditions',
      'en': 'View terms and conditions',
      'ar': 'عرض الشروط والأحكام',
    },
    'Introduction': {
      'fr': 'Introduction',
      'en': 'Introduction',
      'ar': 'مقدمة',
    },
    'Données Collectées': {
      'fr': 'Données Collectées',
      'en': 'Data Collected',
      'ar': 'البيانات المجمعة',
    },
    '❌ Données NON collectées': {
      'fr': '❌ Données NON collectées',
      'en': '❌ Data NOT Collected',
      'ar': '❌ البيانات غير المجمعة',
    },
    '✅ Données utilisées localement': {
      'fr': '✅ Données utilisées localement',
      'en': '✅ Data Used Locally',
      'ar': '✅ البيانات المستخدمة محليًا',
    },
    'Permissions Utilisées': {
      'fr': 'Permissions Utilisées',
      'en': 'Permissions Used',
      'ar': 'الأذونات المستخدمة',
    },
    '📍 Localisation (GPS)': {
      'fr': '📍 Localisation (GPS)',
      'en': '📍 Location (GPS)',
      'ar': '📍 الموقع (GPS)',
    },
    '🌐 Internet': {
      'fr': '🌐 Internet',
      'en': '🌐 Internet',
      'ar': '🌐 الإنترنت',
    },
    '🔔 Notifications': {
      'fr': '🔔 Notifications',
      'en': '🔔 Notifications',
      'ar': '🔔 الإشعارات',
    },
    'Partage de Données': {
      'fr': 'Partage de Données',
      'en': 'Data Sharing',
      'ar': 'مشاركة البيانات',
    },
    'Services Tiers': {
      'fr': 'Services Tiers',
      'en': 'Third-Party Services',
      'ar': 'خدمات الطرف الثالث',
    },
    'Stockage des Données': {
      'fr': 'Stockage des Données',
      'en': 'Data Storage',
      'ar': 'تخزين البيانات',
    },
    'Où sont stockées vos données ?': {
      'fr': 'Où sont stockées vos données ?',
      'en': 'Where is your data stored?',
      'ar': 'أين تُخزن بياناتك؟',
    },
    'Combien de temps ?': {
      'fr': 'Combien de temps ?',
      'en': 'How long?',
      'ar': 'كم المدة؟',
    },
    'Sécurité': {
      'fr': 'Sécurité',
      'en': 'Security',
      'ar': 'الأمان',
    },
    'Droits des Utilisateurs': {
      'fr': 'Droits des Utilisateurs',
      'en': 'User Rights',
      'ar': 'حقوق المستخدم',
    },
    'Enfants et Vie Privée': {
      'fr': 'Enfants et Vie Privée',
      'en': 'Children and Privacy',
      'ar': 'الأطفال والخصوصية',
    },
    'Modifications de cette Politique': {
      'fr': 'Modifications de cette Politique',
      'en': 'Changes to this Policy',
      'ar': 'تعديلات هذه السياسة',
    },
    'Contact': {
      'fr': 'Contact',
      'en': 'Contact',
      'ar': 'اتصل',
    },
    'Pourquoi ?': {
      'fr': 'Pourquoi ?',
      'en': 'Why?',
      'ar': 'لماذا؟',
    },
    'Comment ?': {
      'fr': 'Comment ?',
      'en': 'How?',
      'ar': 'كيف؟',
    },
    'En résumé': {
      'fr': 'En résumé',
      'en': 'In summary',
      'ar': 'ملخص',
    },
    'Résumé en une phrase': {
      'fr': 'Résumé en une phrase',
      'en': 'Summary in one sentence',
      'ar': 'ملخص في جملة واحدة',
    },
    'Dernière mise à jour : 10 mars 2026': {
      'fr': 'Dernière mise à jour : 10 mars 2026',
      'en': 'Last updated: March 10, 2026',
      'ar': 'آخر تحديث: 10 مارس 2026',
    },
    'Cette politique de confidentialité a été créée le 10 mars 2026.': {
      'fr': 'Cette politique de confidentialité a été créée le 10 mars 2026.',
      'en': 'This privacy policy was created on March 10, 2026.',
      'ar': 'تم إنشاء سياسة الخصوصية هذه في 10 مارس 2026.',
    },
    // Privacy Policy Content
    'privacy_intro': {
      'fr': 'Bienvenue sur Houda Al Fourquan. Cette politique de confidentialité explique comment nous traitons vos données lorsque vous utilisez notre application islamique.\n\nNotre engagement : Votre vie privée est notre priorité. Nous avons conçu cette application pour fonctionner avec un minimum de données et un maximum de confidentialité.',
      'en': 'Welcome to Houda Al Fourquan. This privacy policy explains how we process your data when you use our Islamic application.\n\nOur commitment: Your privacy is our priority. We designed this application to work with minimum data and maximum privacy.',
      'ar': 'مرحبًا بكم في تطبيق Houda Al Fourquan. توضح سياسة الخصوصية هذه كيفية معالجة بياناتك عند استخدام تطبيقنا الإسلامي.\n\nالتزامنا: خصوصيتك هي أولويتنا. لقد صممنا هذا التطبيق ليعمل بأقل قدر من البيانات وبأقصى قدر من الخصوصية.',
    },
    'privacy_not_collected': {
      'fr': 'Nous ne collectons AUCUNE des données suivantes : nom, email, téléphone, adresse, historique de navigation, identifiants publicitaires, données de paiement.',
      'en': 'We do NOT collect any of the following: name, email, phone, address, browsing history, advertising identifiers, payment data.',
      'ar': 'نحن لا نجمع أيًا من البيانات التالية: الاسم أو البريد الإلكتروني أو الهاتف أو العنوان أو سجل التصفح أو معرفات الإعلانات أو بيانات الدفع.',
    },
    'privacy_local_data': {
      'fr': 'Les données suivantes sont utilisées UNIQUEMENT sur votre appareil et ne sont JAMAIS transmises :\n\n• Position GPS : Pour calculer les horaires de prière et la direction Qibla\n• Préférences utilisateur : Paramètres stockés localement\n• Historique de lecture : Progression dans le Coran\n• Compteurs Tasbih : Stockés localement',
      'en': 'The following data is used ONLY on your device and is NEVER transmitted:\n\n• GPS Location: To calculate prayer times and Qibla direction\n• User Preferences: Locally stored settings\n• Reading History: Quran reading progress\n• Tasbih Counters: Stored locally',
      'ar': 'البيانات التالية تُستخدم فقط على جهازك ولا تُرسل أبدًا:\n\n• موقع GPS: لحساب أوقات الصلاة واتجاه القبلة\n• تفضيلات المستخدم: الإعدادات المخزنة محليًا\n• سجل القراءة: تقدم قراءة القرآن\n• عدادات التسبيح: مخزنة محليًا',
    },
    'privacy_sharing': {
      'fr': 'Nous ne vendons, ne louons et ne partageons pas vos données à des fins commerciales.\n\nIl n\'y a :\n• ❌ Pas de publicité\n• ❌ Pas d\'analytics\n• ❌ Pas de réseaux sociaux intégrés\n• ❌ Pas de vente de données\n\nDonnées techniques utilisées uniquement pour la fonctionnalité :\n• ✅ Coordonnées GPS (OpenStreetMap Nominatim)\n• ✅ Adresse IP (ipapi.co, localisation de secours)',
      'en': 'We do NOT sell, rent, or share your data for commercial purposes.\n\nThere is:\n• ❌ No advertising\n• ❌ No analytics\n• ❌ No social media integration\n• ❌ No data selling\n\nTechnical data used only for functionality:\n• ✅ GPS coordinates (OpenStreetMap Nominatim)\n• ✅ IP address (ipapi.co, fallback location)',
      'ar': 'نحن لا نبيع أو نؤجر أو نشارك بياناتك لأغراض تجارية.\n\nلا يوجد:\n• ❌ لا إعلانات\n• ❌ لا تحليلات\n• ❌ لا تكامل مع وسائل التواصل الاجتماعي\n• ❌ لا بيع بيانات\n\nبيانات تقنية تُستخدم فقط لتقديم الخدمة:\n• ✅ إحداثيات GPS (OpenStreetMap Nominatim)\n• ✅ عنوان IP (ipapi.co عند الحاجة)',
    },
    'privacy_third_party': {
      'fr': 'L\'application utilise les services suivants pour fournir du contenu :\n\n• Quran.com API : Texte du Coran et traductions\n• EveryAyah.com : Récitations audio\n• OpenStreetMap Nominatim : Géolocalisation des villes (coordonnées GPS)\n• ipapi.co : Localisation par IP (secours si GPS indisponible)\n\nImportant : Aucun compte utilisateur n\'est transmis. Ces services reçoivent uniquement les données nécessaires pour fournir la fonctionnalité.',
      'en': 'The application uses the following services to provide content:\n\n• Quran.com API: Quran text and translations\n• EveryAyah.com: Audio recitations\n• OpenStreetMap Nominatim: City geolocation (GPS coordinates)\n• ipapi.co: IP-based location (fallback if GPS is unavailable)\n\nImportant: No user account is transmitted. These services receive only the data needed to provide functionality.',
      'ar': 'يستخدم التطبيق الخدمات التالية لتوفير المحتوى:\n\n• Quran.com API: نص القرآن والترجمات\n• EveryAyah.com: التلاوات الصوتية\n• OpenStreetMap Nominatim: تحديد المدينة عبر GPS\n• ipapi.co: تحديد الموقع عبر عنوان IP عند الحاجة\n\nمهم: لا يتم إرسال أي حساب مستخدم. تُرسل فقط البيانات اللازمة لتقديم الخدمة.',
    },
    'privacy_storage_where': {
      'fr': 'Toutes vos données sont stockées localement sur votre appareil (iPhone/iPad ou Android).',
      'en': 'All your data is stored locally on your device (iPhone/iPad or Android).',
      'ar': 'جميع بياناتك تُخزن محليًا على جهازك (iPhone/iPad أو Android).',
    },
    'privacy_storage_how_long': {
      'fr': 'Les données sont conservées tant que l\'application est installée. Si vous désinstallez l\'application, toutes les données sont supprimées automatiquement.',
      'en': 'Data is retained as long as the app is installed. If you uninstall the app, all data is automatically deleted.',
      'ar': 'تُحتفظ بالبيانات طالما التطبيق مثبت. إذا قمت بإلغاء تثبيت التطبيق، تُحذف جميع البيانات تلقائيًا.',
    },
    'privacy_security': {
      'fr': 'Bien que nous ne collections pas de données personnelles, nous prenons la sécurité au sérieux :\n\n✅ Les données locales sont stockées dans le bac à sable (sandbox) de l\'application\n✅ Aucune transmission réseau de données personnelles\n✅ Connexions HTTPS sécurisées pour le téléchargement de contenu',
      'en': 'Although we do not collect personal data, we take security seriously:\n\n✅ Local data is stored in the app sandbox\n✅ No network transmission of personal data\n✅ Secure HTTPS connections for content downloads',
      'ar': 'على الرغم من أننا لا نجمع بيانات شخصية، فإننا نأخذ الأمان على محمل الجد:\n\n✅ تُخزن البيانات المحلية في بيئة التطبيق المعزولة\n✅ لا يوجد نقل شبكي للبيانات الشخصية\n✅ اتصالات HTTPS آمنة لتنزيل المحتوى',
    },
    'privacy_rights': {
      'fr': 'Conformément au RGPD (Europe) et autres réglementations, vous avez les droits suivants :\n\n• Droit d\'accès : Vous pouvez voir toutes vos données dans l\'application\n• Droit à la suppression : Désinstallez l\'application pour supprimer toutes vos données\n• Droit à la portabilité : Non applicable (pas de données collectées)\n• Droit d\'opposition : Vous pouvez désactiver la localisation dans les paramètres de votre appareil',
      'en': 'Under GDPR (Europe) and other regulations, you have the following rights:\n\n• Right to access: You can view all your data in the app\n• Right to deletion: Uninstall the app to delete all your data\n• Right to portability: Not applicable (no data collected)\n• Right to object: You can disable location in your device settings',
      'ar': 'بموجب قانون GDPR (أوروبا) واللوائح الأخرى، لديك الحقوق التالية:\n\n• حق الوصول: يمكنك عرض جميع بياناتك في التطبيق\n• حق الحذف: قم بإلغاء تثبيت التطبيق لحذف جميع بياناتك\n• حق النقل: غير منطبق (لا يتم جمع بيانات)\n• حق الاعتراض: يمكنك تعطيل الموقع في إعدادات جهازك',
    },
    'privacy_children': {
      'fr': 'Notre application :\n\n✅ Ne collecte aucune donnée personnelle\n✅ Ne cible pas spécifiquement les enfants de moins de 13 ans\n✅ Est conforme avec la loi COPPA (Children\'s Online Privacy Protection Act)\n\nLes enfants peuvent utiliser l\'application en toute sécurité car aucune donnée n\'est collectée ou transmise.',
      'en': 'Our application:\n\n✅ Does not collect any personal data\n✅ Does not specifically target children under 13\n✅ Is COPPA compliant (Children\'s Online Privacy Protection Act)\n\nChildren can use the app safely as no data is collected or transmitted.',
      'ar': 'تطبيقنا:\n\n✅ لا يجمع أي بيانات شخصية\n✅ لا يستهدف بشكل محدد الأطفال دون سن 13 عامًا\n✅ متوافق مع قانون COPPA (قانون حماية خصوصية الأطفال على الإنترنت)\n\nيمكن للأطفال استخدام التطبيق بأمان حيث لا يتم جمع أو نقل أي بيانات.',
    },
    'privacy_changes': {
      'fr': 'Nous pouvons mettre à jour cette politique de confidentialité. La date de "Dernière mise à jour" en haut de cette page indiquera la date de la dernière modification.\n\nNous vous encourageons à consulter régulièrement cette page pour rester informé de la façon dont nous protégeons vos données.',
      'en': 'We may update this privacy policy. The "Last updated" date at the top of this page will indicate the date of the last modification.\n\nWe encourage you to review this page regularly to stay informed about how we protect your data.',
      'ar': 'قد نقوم بتحديث سياسة الخصوصية هذه. سيُشير تاريخ "آخر تحديث" في أعلى هذه الصفحة إلى تاريخ آخر تعديل.\n\nنشجعك على مراجعة هذه الصفحة بانتظام للبقاء على اطلاع بكيفية حماية بياناتك.',
    },
    'privacy_contact': {
      'fr': 'Si vous avez des questions concernant cette politique de confidentialité ou nos pratiques de données, vous pouvez nous contacter :\n\n📧 Par email : mindcom2018@gmail.com\n📞 Téléphone : +212 6 93 93 62 71',
      'en': 'If you have questions about this privacy policy or our data practices, you can contact us:\n\n📧 By email: mindcom2018@gmail.com\n📞 Phone: +212 6 93 93 62 71',
      'ar': 'إذا كانت لديك أسئلة حول سياسة الخصوصية هذه أو ممارساتنا المتعلقة بالبيانات، يمكنك الاتصال بنا:\n\n📧 عبر البريد الإلكتروني: mindcom2018@gmail.com\n📞 الهاتف: +212 6 93 93 62 71',
    },
    'privacy_summary': {
      'fr': 'Cette application ne collecte ni ne stocke de données personnelles sur nos serveurs.',
      'en': 'This app does not collect or store personal data on our servers.',
      'ar': 'هذا التطبيق لا يجمع ولا يخزن بيانات شخصية على خوادمنا.',
    },
    'privacy_footer': {
      'fr': 'Houda Al Fourquan ne collecte ni ne stocke de données personnelles sur nos serveurs. Les données techniques nécessaires (GPS/IP) sont utilisées uniquement pour fournir le service.',
      'en': 'Houda Al Fourquan does not collect or store personal data on our servers. Necessary technical data (GPS/IP) is used only to provide the service.',
      'ar': 'تطبيق Houda Al Fourquan لا يجمع ولا يخزن بيانات شخصية على خوادمنا. تُستخدم بيانات تقنية لازمة (GPS/IP) فقط لتقديم الخدمة.',
    },
    'privacy_location_why': {
      'fr': 'Calcul précis des horaires de prière et de la direction Qibla',
      'en': 'Accurate calculation of prayer times and Qibla direction',
      'ar': 'الحساب الدقيق لأوقات الصلاة واتجاه القبلة',
    },
    'privacy_location_how': {
      'fr': 'La position est utilisée uniquement pendant l\'utilisation. Elle n\'est pas stockée.',
      'en': 'Location is used only during app usage. It is not stored.',
      'ar': 'يُستخدم الموقع فقط أثناء استخدام التطبيق. لا يتم تخزينه.',
    },
    'privacy_internet_why': {
      'fr': 'Télécharger les récitations audio du Coran et les traductions',
      'en': 'Download Quran audio recitations and translations',
      'ar': 'تنزيل تلاوات القرآن الصوتية والترجمات',
    },
    'privacy_internet_how': {
      'fr': 'Connexion uniquement lors du téléchargement. Aucune donnée n\'est envoyée.',
      'en': 'Connection only during download. No data is sent.',
      'ar': 'الاتصال فقط أثناء التنزيل. لا يتم إرسال أي بيانات.',
    },
    'privacy_notifications_why': {
      'fr': 'Rappels pour les prières et l\'Adhan',
      'en': 'Reminders for prayers and Adhan',
      'ar': 'تذكيرات للصلاة والأذان',
    },
    'privacy_notifications_how': {
      'fr': 'Notifications locales programmées sur votre appareil.',
      'en': 'Local notifications scheduled on your device.',
      'ar': 'إشعارات محلية مجدولة على جهازك.',
    },
    'acceptance': {
      'fr': 'Acceptation des conditions',
      'en': 'Acceptance of Terms',
      'ar': 'قبول الشروط',
    },
    'termsAcceptance': {
      'fr': 'En accédant et en utilisant Houda Al Fourquan, vous acceptez d\'être lié par ces conditions d\'utilisation. Si vous n\'êtes pas d\'accord avec ces conditions, veuillez ne pas utiliser cette application.',
      'en': 'By accessing and using Houda Al Fourquan, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use this application.',
      'ar': 'من خلال الوصول إلى تطبيق Houda Al Fourquan واستخدامه، فإنك توافق على الالتزام بشروط الخدمة هذه. إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام هذا التطبيق.',
    },
    'services': {
      'fr': 'Description des services',
      'en': 'Description of Services',
      'ar': 'وصف الخدمات',
    },
    'servicesDescription': {
      'fr': 'Houda Al Fourquan fournit les services suivants : calcul des heures de prière, direction de la Qibla, lecture du Coran, tasbih numérique, et rappels de prière. Tous les contenus religieux sont fournis à titre informatif uniquement.',
      'en': 'Houda Al Fourquan provides the following services: prayer times calculation, Qibla direction, Quran reading, digital tasbih, and prayer reminders. All religious content is provided for informational purposes only.',
      'ar': 'يوفر تطبيق Houda Al Fourquan الخدمات التالية: حساب أوقات الصلاة، اتجاه القبلة، قراءة القرآن، التسبيح الرقمي، وتذكيرات الصلاة. يتم توفير جميع المحتويات الدينية لأغراض إعلامية فقط.',
    },
    'userResponsibilities': {
      'fr': 'Responsabilités de l\'utilisateur',
      'en': 'User Responsibilities',
      'ar': 'مسؤوليات المستخدم',
    },
    'accurateInfo': {
      'fr': 'Vous êtes responsable de fournir des informations exactes pour le calcul des prières.',
      'en': 'You are responsible for providing accurate information for prayer calculations.',
      'ar': 'أنت مسؤول عن تقديم معلومات دقيقة لحسابات الصلاة.',
    },
    'respectfulUse': {
      'fr': 'Vous devez utiliser l\'application d\'une manière respectueuse de sa nature religieuse.',
      'en': 'You must use the application in a manner respectful of its religious nature.',
      'ar': 'يجب عليك استخدام التطبيق بطريقة تحترم طابعه الديني.',
    },
    'noMisuse': {
      'fr': 'Vous ne devez pas utiliser l\'application à des fins illégales ou interdites.',
      'en': 'You must not use the application for any unlawful or prohibited purposes.',
      'ar': 'يجب عدم استخدام التطبيق لأي أغراض غير قانونية أو محظورة.',
    },
    'privacyCompliance': {
      'fr': 'Vous devez respecter notre politique de confidentialité.',
      'en': 'You must comply with our Privacy Policy.',
      'ar': 'يجب عليك الالتزام بسياسة الخصوصية الخاصة بنا.',
    },
    'intellectualProperty': {
      'fr': 'Propriété intellectuelle',
      'en': 'Intellectual Property Rights',
      'ar': 'حقوق الملكية الفكرية',
    },
    'ipRights': {
      'fr': 'Tout le contenu de Houda Al Fourquan (texte, design, code, logos) est protégé par les droits d\'auteur et de propriété intellectuelle. Vous ne pouvez pas copier, modifier ou distribuer le contenu sans autorisation écrite.',
      'en': 'All content in Houda Al Fourquan (text, design, code, logos) is protected by copyright and intellectual property rights. You may not copy, modify, or distribute content without written permission.',
      'ar': 'جميع المحتويات في تطبيق Houda Al Fourquan (النص، التصميم، الكود، الشعارات) محمية بحقوق الطبع والنشر والملكية الفكرية. لا يجوز نسخ أو تعديل أو توزيع المحتوى دون إذن كتابي.',
    },
    'prohibitedConduct': {
      'fr': 'Conduite interdite',
      'en': 'Prohibited Conduct',
      'ar': 'السلوك المحظور',
    },
    'noIllegalActivities': {
      'fr': 'Aucune activité illégale ou frauduleuse.',
      'en': 'No illegal or fraudulent activities.',
      'ar': 'لا أنشطة غير قانونية أو احتيالية.',
    },
    'noHarassment': {
      'fr': 'Aucun harcèlement, abus ou comportement offensant.',
      'en': 'No harassment, abuse, or offensive behavior.',
      'ar': 'لا مضايقة أو إساءة أو سلوك مسيء.',
    },
    'noInterference': {
      'fr': 'Aucune interférence avec les serveurs ou réseaux de l\'application.',
      'en': 'No interference with application servers or networks.',
      'ar': 'لا تداخل مع خوادم أو شبكات التطبيق.',
    },
    'noCommercialUse': {
      'fr': 'Aucune utilisation commerciale sans autorisation.',
      'en': 'No commercial use without permission.',
      'ar': 'لا استخدام تجاري دون إذن.',
    },
    'disclaimer': {
      'fr': 'Avertissement religieux',
      'en': 'Religious Disclaimer',
      'ar': 'إخلاء مسؤولية ديني',
    },
    'disclaimerContent': {
      'fr': 'Les horaires de prière et informations religieuses sont fournis à titre indicatif. Nous ne garantissons pas l\'exactitude absolue. Veuillez consulter les autorités religieuses locales pour les horaires officiels.',
      'en': 'Prayer times and religious information are provided for guidance only. We do not guarantee absolute accuracy. Please consult local religious authorities for official times.',
      'ar': 'أوقات الصلاة والمعلومات الدينية مقدمة للإرشاد فقط. لا نضمن الدقة المطلقة. يرجى استشارة السلطات الدينية المحلية للحصول على الأوقات الرسمية.',
    },
    'limitationOfLiability': {
      'fr': 'Limitation de responsabilité',
      'en': 'Limitation of Liability',
      'ar': 'تحديد المسؤولية',
    },
    'liabilityLimitation': {
      'fr': 'Houda Al Fourquan est fourni "tel quel" sans garantie. Nous ne sommes pas responsables des erreurs, omissions, ou dommages résultant de l\'utilisation de cette application.',
      'en': 'Houda Al Fourquan is provided "as is" without warranties. We are not liable for any errors, omissions, or damages resulting from the use of this application.',
      'ar': 'يتم توفير تطبيق Houda Al Fourquan "كما هو" بدون ضمانات. نحن غير مسؤولين عن أي أخطاء أو إغفالات أو أضرار ناتجة عن استخدام هذا التطبيق.',
    },
    'modifications': {
      'fr': 'Modifications des conditions',
      'en': 'Modifications to Terms',
      'ar': 'تعديلات الشروط',
    },
    'termsModifications': {
      'fr': 'Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications prennent effet immédiatement après publication dans l\'application.',
      'en': 'We reserve the right to modify these terms at any time. Modifications take effect immediately upon posting in the application.',
      'ar': 'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. تدخل التعديلات حيز التنفيذ فور نشرها في التطبيق.',
    },
    'termination': {
      'fr': 'Résiliation du compte',
      'en': 'Account Termination',
      'ar': 'إنهاء الحساب',
    },
    'accountTermination': {
      'fr': 'Nous nous réservons le droit de suspendre ou résilier votre accès à l\'application pour violation de ces conditions.',
      'en': 'We reserve the right to suspend or terminate your access to the application for violation of these terms.',
      'ar': 'نحتفظ بالحق في تعليق أو إنهاء وصولك إلى التطبيق لانتهاك هذه الشروط.',
    },
    'governingLaw': {
      'fr': 'Loi applicable',
      'en': 'Governing Law',
      'ar': 'القانون الواجب التطبيق',
    },
    'governingLawContent': {
      'fr': 'Ces conditions sont régies par les lois en vigueur. Tout litige sera soumis aux tribunaux compétents.',
      'en': 'These terms are governed by applicable laws. Any disputes shall be submitted to competent courts.',
      'ar': 'تخضع هذه الشروط للقوانين السارية. يتم تقديم أي نزاعات للمحاكم المختصة.',
    },
    'contact': {
      'fr': 'Contact',
      'en': 'Contact Information',
      'ar': 'معلومات الاتصال',
    },
    'contactInfo': {
      'fr': 'Pour toute question concernant ces conditions, contactez-nous :\n\n📧 Email : mindcom2018@gmail.com\n📞 Téléphone : +212 6 93 93 62 71',
      'en': 'For any questions regarding these terms, contact us:\n\n📧 Email: mindcom2018@gmail.com\n📞 Phone: +212 6 93 93 62 71',
      'ar': 'لأي أسئلة تتعلق بهذه الشروط، اتصل بنا:\n\n📧 البريد الإلكتروني: mindcom2018@gmail.com\n📞 الهاتف: +212 6 93 93 62 71',
    },
    'importantNotice': {
      'fr': 'Avis important',
      'en': 'Important Notice',
      'ar': 'إشعار مهم',
    },
    'legalBindingNotice': {
      'fr': 'Ces conditions constituent un accord juridiquement contraignant entre vous et Houda Al Fourquan. Veuillez les lire attentivement avant d\'utiliser l\'application.',
      'en': 'These terms constitute a legally binding agreement between you and Houda Al Fourquan. Please read them carefully before using the application.',
      'ar': 'تشكل هذه الشروط اتفاقية ملزمة قانونًا بينك وبين تطبيق Houda Al Fourquan. يرجى قراءتها بعناية قبل استخدام التطبيق.',
    },
    'Last updated: March 10, 2026': {
      'fr': 'Dernière mise à jour : 10 mars 2026',
      'en': 'Last updated: March 10, 2026',
      'ar': 'آخر تحديث: 10 مارس 2026',
    },
    'These terms were last updated on March 10, 2026.': {
      'fr': 'Ces conditions ont été mises à jour pour la dernière fois le 10 mars 2026.',
      'en': 'These terms were last updated on March 10, 2026.',
      'ar': 'تم آخر تحديث لهذه الشروط في 10 مارس 2026.',
    },
  };
}
