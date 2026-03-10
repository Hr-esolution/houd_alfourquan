import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  late GetStorage _storage;
  String _currentLang = 'fr';

  String get currentLang => _currentLang;
  bool get isArabic => _currentLang == 'ar';
  bool get isFrench => _currentLang == 'fr';
  bool get isEnglish => _currentLang == 'en';

  @override
  void onInit() {
    super.onInit();
    _storage = GetStorage();
    _currentLang = _storage.read('app_language') ?? 'fr';
  }

  Future<void> setLanguage(String langCode) async {
    if (['fr', 'en', 'ar'].contains(langCode)) {
      _currentLang = langCode;
      await _storage.write('app_language', langCode);
      Get.updateLocale(Locale(langCode));
      update(); // Notify GetBuilder listeners
    }
  }

  Future<void> toggleLanguage() async {
    final nextLang = _currentLang == 'fr'
        ? 'en'
        : (_currentLang == 'en' ? 'ar' : 'fr');
    await setLanguage(nextLang);
  }

  String getDirection() {
    return _currentLang == 'ar' ? 'rtl' : 'ltr';
  }

  TextAlign getTextAlign() {
    return _currentLang == 'ar' ? TextAlign.right : TextAlign.left;
  }

  // Translation method
  String translate(String key) {
    return _translations[key]?[_currentLang] ?? key;
  }
}

// Extension for translations (avoid conflict with GetX)
extension AppTranslations on String {
  String get trx {
    final langController = Get.find<LanguageController>();
    return langController.translate(this);
  }
}

// Translations map - Complete UI translations
const Map<String, Map<String, String>> _translations = {
  // ═══════════════════════════════════════════════════════════════
  //  APP GENERAL
  // ═══════════════════════════════════════════════════════════════
  'Salat': {
    'fr': 'Houda Al Fourquan',
    'en': 'Houda Al Fourquan',
    'ar': 'هدى الفرقان',
  },
  'Prayer Times': {
    'fr': 'Heures de prière',
    'en': 'Prayer Times',
    'ar': 'أوقات الصلاة',
  },

  // ═══════════════════════════════════════════════════════════════
  //  NAVIGATION
  // ═══════════════════════════════════════════════════════════════
  'Home': {
    'fr': 'Accueil',
    'en': 'Home',
    'ar': 'الرئيسية',
  },
  'Qibla': {
    'fr': 'Qibla',
    'en': 'Qibla',
    'ar': 'القبلة',
  },
  'Tasbih': {
    'fr': 'Tasbih',
    'en': 'Tasbih',
    'ar': 'التسبيح',
  },
  'Quran': {
    'fr': 'Coran',
    'en': 'Quran',
    'ar': 'القرآن',
  },
  'Settings': {
    'fr': 'Paramètres',
    'en': 'Settings',
    'ar': 'الإعدادات',
  },
  'Prayer': {
    'fr': 'Prière',
    'en': 'Prayer',
    'ar': 'الصلاة',
  },

  // ═══════════════════════════════════════════════════════════════
  //  HOME PAGE
  // ═══════════════════════════════════════════════════════════════
  'Accueil': {
    'fr': 'Accueil',
    'en': 'Home',
    'ar': 'الرئيسية',
  },
  'Mode clair': {
    'fr': 'Mode clair',
    'en': 'Light mode',
    'ar': 'الوضع الفاتح',
  },
  'Mode sombre': {
    'fr': 'Mode sombre',
    'en': 'Dark mode',
    'ar': 'الوضع الداكن',
  },
  'Ramadan': {
    'fr': 'Ramadan',
    'en': 'Ramadan',
    'ar': 'رمضان',
  },
  'Fajr': {
    'fr': 'Fajr',
    'en': 'Fajr',
    'ar': 'الفجر',
  },
  'Dhuhr': {
    'fr': 'Dhuhr',
    'en': 'Dhuhr',
    'ar': 'الظهر',
  },
  'Asr': {
    'fr': 'Asr',
    'en': 'Asr',
    'ar': 'العصر',
  },
  'Maghrib': {
    'fr': 'Maghrib',
    'en': 'Maghrib',
    'ar': 'المغرب',
  },
  'Isha': {
    'fr': 'Isha',
    'en': 'Isha',
    'ar': 'العشاء',
  },
  'dans': {
    'fr': 'dans',
    'en': 'in',
    'ar': 'في',
  },
  'Aujourd\'hui': {
    'fr': 'Aujourd\'hui',
    'en': 'Today',
    'ar': 'اليوم',
  },

  // ═══════════════════════════════════════════════════════════════
  //  QURAN PAGE
  // ═══════════════════════════════════════════════════════════════
  'Holy Quran': {
    'fr': 'Saint Coran',
    'en': 'Holy Quran',
    'ar': 'القرآن الكريم',
  },
  'Select Reciter': {
    'fr': 'Choisir le récitateurs',
    'en': 'Select Reciter',
    'ar': 'اختر القارئ',
  },
  'Download Surahs': {
    'fr': 'Télécharger les sourates',
    'en': 'Download Surahs',
    'ar': 'تحميل السور',
  },
  'All Surahs': {
    'fr': 'Toutes les sourates',
    'en': 'All Surahs',
    'ar': 'جميع السور',
  },
  'surahs downloaded': {
    'fr': 'sourates téléchargées',
    'en': 'surahs downloaded',
    'ar': 'السور المحملة',
  },
  'Now playing': {
    'fr': 'En lecture',
    'en': 'Now playing',
    'ar': 'جاري التشغيل',
  },
  'Download for offline': {
    'fr': 'Télécharger pour écoute hors ligne',
    'en': 'Download for offline',
    'ar': 'تحميل للاستماع بدون إنترنت',
  },
  'Download All': {
    'fr': 'Tout télécharger',
    'en': 'Download All',
    'ar': 'تحميل الكل',
  },
  'Downloaded': {
    'fr': 'Téléchargé',
    'en': 'Downloaded',
    'ar': 'تم التحميل',
  },
  'Delete': {
    'fr': 'Supprimer',
    'en': 'Delete',
    'ar': 'حذف',
  },
  'Download': {
    'fr': 'Télécharger',
    'en': 'Download',
    'ar': 'تحميل',
  },
  'Downloading': {
    'fr': 'Téléchargement',
    'en': 'Downloading',
    'ar': 'جاري التحميل',
  },
  'used': {
    'fr': 'utilisé',
    'en': 'used',
    'ar': 'مستخدم',
  },
  'Selected': {
    'fr': 'Sélectionné',
    'en': 'Selected',
    'ar': 'محدد',
  },
  'Refresh': {
    'fr': 'Actualiser',
    'en': 'Refresh',
    'ar': 'تحديث',
  },
  'Reset Cache': {
    'fr': 'Réinitialiser le cache',
    'en': 'Reset Cache',
    'ar': 'إعادة تعيين الذاكرة',
  },
  'Cancel': {
    'fr': 'Annuler',
    'en': 'Cancel',
    'ar': 'إلغاء',
  },
  'Complete': {
    'fr': 'Terminé',
    'en': 'Complete',
    'ar': 'اكتمل',
  },
  'Success': {
    'fr': 'Succès',
    'en': 'Success',
    'ar': 'نجاح',
  },
  'Error': {
    'fr': 'Erreur',
    'en': 'Error',
    'ar': 'خطأ',
  },
  'Loading Quran data...': {
    'fr': 'Chargement du Coran...',
    'en': 'Loading Quran data...',
    'ar': 'جاري تحميل بيانات القرآن...',
  },
  'Loading reciters...': {
    'fr': 'Chargement des récitateurs...',
    'en': 'Loading reciters...',
    'ar': 'جاري تحميل القراء...',
  },
  'Select a reciter': {
    'fr': 'Choisir un récitateurs',
    'en': 'Select a reciter',
    'ar': 'اختر قارئ',
  },
  'End of Surah': {
    'fr': 'Fin de la sourate',
    'en': 'End of Surah',
    'ar': 'نهاية السورة',
  },
  'Auto-scroll': {
    'fr': 'Défilement auto',
    'en': 'Auto-scroll',
    'ar': 'تمرير تلقائي',
  },
  'Pause': {
    'fr': 'Pause',
    'en': 'Pause',
    'ar': 'إيقاف',
  },
  'Go to top': {
    'fr': 'Aller en haut',
    'en': 'Go to top',
    'ar': 'الذهاب للأعلى',
  },
  'Ayahs': {
    'fr': 'Verset',
    'en': 'Ayahs',
    'ar': 'آيات',
  },
  'Chargement du texte...': {
    'fr': 'Chargement du texte...',
    'en': 'Loading text...',
    'ar': 'جاري تحميل النص...',
  },

  // ═══════════════════════════════════════════════════════════════
  //  TASBIH PAGE
  // ═══════════════════════════════════════════════════════════════
  'History': {
    'fr': 'Historique',
    'en': 'History',
    'ar': 'السجل',
  },
  'Target': {
    'fr': 'Objectif',
    'en': 'Target',
    'ar': 'الهدف',
  },
  'Presets': {
    'fr': 'Préréglages',
    'en': 'Presets',
    'ar': 'الإعدادات المسبقة',
  },
  'Reset': {
    'fr': 'Réinitialiser',
    'en': 'Reset',
    'ar': 'إعادة تعيين',
  },
  'Count': {
    'fr': 'Compter',
    'en': 'Count',
    'ar': 'عد',
  },
  'Close': {
    'fr': 'Fermer',
    'en': 'Close',
    'ar': 'إغلاق',
  },
  'No tasbih selected': {
    'fr': 'Aucun tasbih sélectionné',
    'en': 'No tasbih selected',
    'ar': 'لم يتم اختيار تسبيحة',
  },
  'Masha\'Allah !': {
    'fr': 'Masha\'Allah !',
    'en': 'Masha\'Allah!',
    'ar': 'ما شاء الله!',
  },
  'Vous avez complété': {
    'fr': 'Vous avez complété',
    'en': 'You have completed',
    'ar': 'لقد أكملت',
  },
  'Réinitialisé': {
    'fr': 'Réinitialisé',
    'en': 'Reset',
    'ar': 'تمت إعادة التعيين',
  },
  'Tous les compteurs ont été réinitialisés': {
    'fr': 'Tous les compteurs ont été réinitialisés',
    'en': 'All counters have been reset',
    'ar': 'تمت إعادة تعيين جميع العدادات',
  },

  // ═══════════════════════════════════════════════════════════════
  //  SETTINGS PAGE
  // ═══════════════════════════════════════════════════════════════
  'Language': {
    'fr': 'Langue',
    'en': 'Language',
    'ar': 'اللغة',
  },
  'Dark Mode': {
    'fr': 'Mode sombre',
    'en': 'Dark Mode',
    'ar': 'الوضع الداكن',
  },
  'Notifications': {
    'fr': 'Notifications',
    'en': 'Notifications',
    'ar': 'الإشعارات',
  },
  'About': {
    'fr': 'À propos',
    'en': 'About',
    'ar': 'حول',
  },
  'Prayer Notifications': {
    'fr': 'Notifications de prière',
    'en': 'Prayer Notifications',
    'ar': 'إشعارات الصلاة',
  },
  'Get notified before each prayer': {
    'fr': 'Être notifié avant chaque prière',
    'en': 'Get notified before each prayer',
    'ar': 'احصل على إشعار قبل كل صلاة',
  },
  'Adhan Sound': {
    'fr': 'Son Adhan',
    'en': 'Adhan Sound',
    'ar': 'صوت الأذان',
  },
  'Play adhan sound at prayer time': {
    'fr': 'Jouer l\'adhan à l\'heure de prière',
    'en': 'Play adhan sound at prayer time',
    'ar': 'تشغيل الأذان في وقت الصلاة',
  },
  'Fajr Reminder': {
    'fr': 'Rappel Fajr',
    'en': 'Fajr Reminder',
    'ar': 'تذكير الفجر',
  },
  'Special reminder for Fajr prayer': {
    'fr': 'Rappel spécial pour la prière Fajr',
    'en': 'Special reminder for Fajr prayer',
    'ar': 'تذكير خاص لصلاة الفجر',
  },
  'Prayer Settings': {
    'fr': 'Paramètres de prière',
    'en': 'Prayer Settings',
    'ar': 'إعدادات الصلاة',
  },
  'Calculation Method': {
    'fr': 'Méthode de calcul',
    'en': 'Calculation Method',
    'ar': 'طريقة الحساب',
  },
  'Asr Method': {
    'fr': 'Méthode Asr',
    'en': 'Asr Method',
    'ar': 'طريقة العصر',
  },
  'Hijri Adjustment': {
    'fr': 'Ajustement Hijri',
    'en': 'Hijri Adjustment',
    'ar': 'تعديل هجري',
  },
  'Adjust Hijri date display': {
    'fr': 'Ajuster l\'affichage de la date Hijri',
    'en': 'Adjust Hijri date display',
    'ar': 'تعديل عرض التاريخ الهجري',
  },
  'Appearance': {
    'fr': 'Apparence',
    'en': 'Appearance',
    'ar': 'المظهر',
  },
  'Use dark theme': {
    'fr': 'Utiliser le thème sombre',
    'en': 'Use dark theme',
    'ar': 'استخدام المظهر الداكن',
  },
  'App Version': {
    'fr': 'Version de l\'app',
    'en': 'App Version',
    'ar': 'إصدار التطبيق',
  },
  'Privacy Policy': {
    'fr': 'Politique de confidentialité',
    'en': 'Privacy Policy',
    'ar': 'سياسة الخصوصية',
  },
  'Read our privacy policy': {
    'fr': 'Lire notre politique de confidentialité',
    'en': 'Read our privacy policy',
    'ar': 'اقرأ سياسة الخصوصية لدينا',
  },
  'Rate App': {
    'fr': 'Évaluer l\'app',
    'en': 'Rate App',
    'ar': 'تقييم التطبيق',
  },
  'Share your experience': {
    'fr': 'Partagez votre expérience',
    'en': 'Share your experience',
    'ar': 'شارك تجربتك',
  },
  'Reset to Defaults': {
    'fr': 'Réinitialiser',
    'en': 'Reset to Defaults',
    'ar': 'إعادة التعيين',
  },
  'Restore original settings': {
    'fr': 'Restaurer les paramètres d\'origine',
    'en': 'Restore original settings',
    'ar': 'استعادة الإعدادات الأصلية',
  },

  // ═══════════════════════════════════════════════════════════════
  //  COMMON
  // ═══════════════════════════════════════════════════════════════
  'Loading': {
    'fr': 'Chargement',
    'en': 'Loading',
    'ar': 'جاري التحميل',
  },
  'Please select a reciter first': {
    'fr': 'Veuillez d\'abord choisir un récitateurs',
    'en': 'Please select a reciter first',
    'ar': 'الرجاء اختيار القارئ أولاً',
  },
  'No Connection': {
    'fr': 'Pas de connexion',
    'en': 'No Connection',
    'ar': 'لا يوجد اتصال',
  },
  'Permission Denied': {
    'fr': 'Permission refusée',
    'en': 'Permission Denied',
    'ar': 'تم رفض الإذن',
  },
  'Direction': {
    'fr': 'Direction',
    'en': 'Direction',
    'ar': 'الاتجاه',
  },
  'Dhikr': {
    'fr': 'Dhikr',
    'en': 'Dhikr',
    'ar': 'الذكر',
  },
  'Listen': {
    'fr': 'Écouter',
    'en': 'Listen',
    'ar': 'استماع',
  },
  'Quick Access': {
    'fr': 'Accès rapide',
    'en': 'Quick Access',
    'ar': 'الوصول السريع',
  },
  'verses': {
    'fr': 'versets',
    'en': 'verses',
    'ar': 'آيات',
  },
  'Standard (Shafi)': {
    'fr': 'Standard (Shafi)',
    'en': 'Standard (Shafi)',
    'ar': 'قياسي (شافعي)',
  },
  'Hanafi': {
    'fr': 'Hanafi',
    'en': 'Hanafi',
    'ar': 'حنفي',
  },
  'Muslim World League': {
    'fr': 'Ligue Musulmane Mondiale',
    'en': 'Muslim World League',
    'ar': 'رابطة العالم الإسلامي',
  },
  'Egyptian': {
    'fr': 'Égyptien',
    'en': 'Egyptian',
    'ar': 'المصرية',
  },
  'Karachi': {
    'fr': 'Karachi',
    'en': 'Karachi',
    'ar': 'كراتشي',
  },
  'Umm al-Qura': {
    'fr': 'Umm al-Qura',
    'en': 'Umm al-Qura',
    'ar': 'أم القرى',
  },
  'Dubai': {
    'fr': 'Dubaï',
    'en': 'Dubai',
    'ar': 'دبي',
  },
  'English': {
    'fr': 'Anglais',
    'en': 'English',
    'ar': 'الإنجليزية',
  },
  'Arabic': {
    'fr': 'Arabe',
    'en': 'Arabic',
    'ar': 'العربية',
  },
  'French': {
    'fr': 'Français',
    'en': 'French',
    'ar': 'الفرنسية',
  },
  'Urdu': {
    'fr': 'Ourdou',
    'en': 'Urdu',
    'ar': 'الأردية',
  },
  'Français': {
    'fr': 'Français',
    'en': 'French',
    'ar': 'الفرنسية',
  },
  'العربية': {
    'fr': 'Arabe',
    'en': 'Arabic',
    'ar': 'العربية',
  },

  // ═══════════════════════════════════════════════════════════════
  //  QURAN - SURAH NAMES (114)
  // ═══════════════════════════════════════════════════════════════
  'Al-Fatiha': {
    'fr': 'Al-Fatiha',
    'en': 'Al-Fatiha',
    'ar': 'الفاتحة',
  },
  'Al-Baqara': {
    'fr': 'Al-Baqara',
    'en': 'Al-Baqara',
    'ar': 'البقرة',
  },
  'Ali \'Imran': {
    'fr': 'Ali \'Imran',
    'en': 'Ali \'Imran',
    'ar': 'آل عمران',
  },
  'An-Nisa': {
    'fr': 'An-Nisa',
    'en': 'An-Nisa',
    'ar': 'النساء',
  },
  'Al-Ma\'ida': {
    'fr': 'Al-Ma\'ida',
    'en': 'Al-Ma\'ida',
    'ar': 'المائدة',
  },
  'Al-An\'am': {
    'fr': 'Al-An\'am',
    'en': 'Al-An\'am',
    'ar': 'الأنعام',
  },
  'Al-A\'raf': {
    'fr': 'Al-A\'raf',
    'en': 'Al-A\'raf',
    'ar': 'الأعراف',
  },
  'Al-Anfal': {
    'fr': 'Al-Anfal',
    'en': 'Al-Anfal',
    'ar': 'الأنفال',
  },
  'At-Tawba': {
    'fr': 'At-Tawba',
    'en': 'At-Tawba',
    'ar': 'التوبة',
  },
  'Yunus': {
    'fr': 'Yunus',
    'en': 'Yunus',
    'ar': 'يونس',
  },
  'Hud': {
    'fr': 'Hud',
    'en': 'Hud',
    'ar': 'هود',
  },
  'Yusuf': {
    'fr': 'Yusuf',
    'en': 'Yusuf',
    'ar': 'يوسف',
  },
  'Ar-Ra\'d': {
    'fr': 'Ar-Ra\'d',
    'en': 'Ar-Ra\'d',
    'ar': 'الرعد',
  },
  'Ibrahim': {
    'fr': 'Ibrahim',
    'en': 'Ibrahim',
    'ar': 'ابراهيم',
  },
  'Al-Hijr': {
    'fr': 'Al-Hijr',
    'en': 'Al-Hijr',
    'ar': 'الحجر',
  },
  'An-Nahl': {
    'fr': 'An-Nahl',
    'en': 'An-Nahl',
    'ar': 'النحل',
  },
  'Al-Isra': {
    'fr': 'Al-Isra',
    'en': 'Al-Isra',
    'ar': 'الإسراء',
  },
  'Al-Kahf': {
    'fr': 'Al-Kahf',
    'en': 'Al-Kahf',
    'ar': 'الكهف',
  },
  'Maryam': {
    'fr': 'Maryam',
    'en': 'Maryam',
    'ar': 'مريم',
  },
  'Taha': {
    'fr': 'Taha',
    'en': 'Taha',
    'ar': 'طه',
  },
  'Al-Anbya': {
    'fr': 'Al-Anbya',
    'en': 'Al-Anbya',
    'ar': 'الأنبياء',
  },
  'Al-Hajj': {
    'fr': 'Al-Hajj',
    'en': 'Al-Hajj',
    'ar': 'الحج',
  },
  'Al-Mu\'minun': {
    'fr': 'Al-Mu\'minun',
    'en': 'Al-Mu\'minun',
    'ar': 'المؤمنون',
  },
  'An-Nur': {
    'fr': 'An-Nur',
    'en': 'An-Nur',
    'ar': 'النور',
  },
  'Al-Furqan': {
    'fr': 'Al-Furqan',
    'en': 'Al-Furqan',
    'ar': 'الفرقان',
  },
  'Ash-Shu\'ara': {
    'fr': 'Ash-Shu\'ara',
    'en': 'Ash-Shu\'ara',
    'ar': 'الشعراء',
  },
  'An-Naml': {
    'fr': 'An-Naml',
    'en': 'An-Naml',
    'ar': 'النمل',
  },
  'Al-Qasas': {
    'fr': 'Al-Qasas',
    'en': 'Al-Qasas',
    'ar': 'القصص',
  },
  'Al-Ankabut': {
    'fr': 'Al-Ankabut',
    'en': 'Al-Ankabut',
    'ar': 'العنكبوت',
  },
  'Ar-Rum': {
    'fr': 'Ar-Rum',
    'en': 'Ar-Rum',
    'ar': 'الروم',
  },
  'Luqman': {
    'fr': 'Luqman',
    'en': 'Luqman',
    'ar': 'لقمان',
  },
  'As-Sajda': {
    'fr': 'As-Sajda',
    'en': 'As-Sajda',
    'ar': 'السجدة',
  },
  'Al-Ahzab': {
    'fr': 'Al-Ahzab',
    'en': 'Al-Ahzab',
    'ar': 'الأحزاب',
  },
  'Saba': {
    'fr': 'Saba',
    'en': 'Saba',
    'ar': 'سبأ',
  },
  'Fatir': {
    'fr': 'Fatir',
    'en': 'Fatir',
    'ar': 'فاطر',
  },
  'Ya-Sin': {
    'fr': 'Ya-Sin',
    'en': 'Ya-Sin',
    'ar': 'يس',
  },
  'As-Saffat': {
    'fr': 'As-Saffat',
    'en': 'As-Saffat',
    'ar': 'الصافات',
  },
  'Sad': {
    'fr': 'Sad',
    'en': 'Sad',
    'ar': 'ص',
  },
  'Az-Zumar': {
    'fr': 'Az-Zumar',
    'en': 'Az-Zumar',
    'ar': 'الزمر',
  },
  'Ghafir': {
    'fr': 'Ghafir',
    'en': 'Ghafir',
    'ar': 'غافر',
  },
  'Fussilat': {
    'fr': 'Fussilat',
    'en': 'Fussilat',
    'ar': 'فصلت',
  },
  'Ash-Shura': {
    'fr': 'Ash-Shura',
    'en': 'Ash-Shura',
    'ar': 'الشورى',
  },
  'Az-Zukhruf': {
    'fr': 'Az-Zukhruf',
    'en': 'Az-Zukhruf',
    'ar': 'الزخرف',
  },
  'Ad-Dukhan': {
    'fr': 'Ad-Dukhan',
    'en': 'Ad-Dukhan',
    'ar': 'الدخان',
  },
  'Al-Jathiya': {
    'fr': 'Al-Jathiya',
    'en': 'Al-Jathiya',
    'ar': 'الجاثية',
  },
  'Al-Ahqaf': {
    'fr': 'Al-Ahqaf',
    'en': 'Al-Ahqaf',
    'ar': 'الأحقاف',
  },
  'Muhammad': {
    'fr': 'Muhammad',
    'en': 'Muhammad',
    'ar': 'محمد',
  },
  'Al-Fath': {
    'fr': 'Al-Fath',
    'en': 'Al-Fath',
    'ar': 'الفتح',
  },
  'Al-Hujurat': {
    'fr': 'Al-Hujurat',
    'en': 'Al-Hujurat',
    'ar': 'الحجرات',
  },
  'Qaf': {
    'fr': 'Qaf',
    'en': 'Qaf',
    'ar': 'ق',
  },
  'Adh-Dhariyat': {
    'fr': 'Adh-Dhariyat',
    'en': 'Adh-Dhariyat',
    'ar': 'الذاريات',
  },
  'At-Tur': {
    'fr': 'At-Tur',
    'en': 'At-Tur',
    'ar': 'الطور',
  },
  'An-Najm': {
    'fr': 'An-Najm',
    'en': 'An-Najm',
    'ar': 'النجم',
  },
  'Al-Qamar': {
    'fr': 'Al-Qamar',
    'en': 'Al-Qamar',
    'ar': 'القمر',
  },
  'Ar-Rahman': {
    'fr': 'Ar-Rahman',
    'en': 'Ar-Rahman',
    'ar': 'الرحمن',
  },
  'Al-Waqi\'a': {
    'fr': 'Al-Waqi\'a',
    'en': 'Al-Waqi\'a',
    'ar': 'الواقعة',
  },
  'Al-Hadid': {
    'fr': 'Al-Hadid',
    'en': 'Al-Hadid',
    'ar': 'الحديد',
  },
  'Al-Mujadila': {
    'fr': 'Al-Mujadila',
    'en': 'Al-Mujadila',
    'ar': 'المجادلة',
  },
  'Al-Hashr': {
    'fr': 'Al-Hashr',
    'en': 'Al-Hashr',
    'ar': 'الحشر',
  },
  'Al-Mumtahina': {
    'fr': 'Al-Mumtahina',
    'en': 'Al-Mumtahina',
    'ar': 'الممتحنة',
  },
  'As-Saff': {
    'fr': 'As-Saff',
    'en': 'As-Saff',
    'ar': 'الصف',
  },
  'Al-Jumu\'a': {
    'fr': 'Al-Jumu\'a',
    'en': 'Al-Jumu\'a',
    'ar': 'الجمعة',
  },
  'Al-Munafiqun': {
    'fr': 'Al-Munafiqun',
    'en': 'Al-Munafiqun',
    'ar': 'المنافقون',
  },
  'At-Taghabun': {
    'fr': 'At-Taghabun',
    'en': 'At-Taghabun',
    'ar': 'التغابن',
  },
  'At-Talaq': {
    'fr': 'At-Talaq',
    'en': 'At-Talaq',
    'ar': 'الطلاق',
  },
  'At-Tahrim': {
    'fr': 'At-Tahrim',
    'en': 'At-Tahrim',
    'ar': 'التحريم',
  },
  'Al-Mulk': {
    'fr': 'Al-Mulk',
    'en': 'Al-Mulk',
    'ar': 'الملك',
  },
  'Al-Qalam': {
    'fr': 'Al-Qalam',
    'en': 'Al-Qalam',
    'ar': 'القلم',
  },
  'Al-Haqqa': {
    'fr': 'Al-Haqqa',
    'en': 'Al-Haqqa',
    'ar': 'الحاقة',
  },
  'Al-Ma\'arij': {
    'fr': 'Al-Ma\'arij',
    'en': 'Al-Ma\'arij',
    'ar': 'المعارج',
  },
  'Nuh': {
    'fr': 'Nuh',
    'en': 'Nuh',
    'ar': 'نوح',
  },
  'Al-Jinn': {
    'fr': 'Al-Jinn',
    'en': 'Al-Jinn',
    'ar': 'الجن',
  },
  'Al-Muzzammil': {
    'fr': 'Al-Muzzammil',
    'en': 'Al-Muzzammil',
    'ar': 'المزمل',
  },
  'Al-Muddaththir': {
    'fr': 'Al-Muddaththir',
    'en': 'Al-Muddaththir',
    'ar': 'المدثر',
  },
  'Al-Qiyama': {
    'fr': 'Al-Qiyama',
    'en': 'Al-Qiyama',
    'ar': 'القيامة',
  },
  'Al-Insan': {
    'fr': 'Al-Insan',
    'en': 'Al-Insan',
    'ar': 'الانسان',
  },
  'Al-Mursalat': {
    'fr': 'Al-Mursalat',
    'en': 'Al-Mursalat',
    'ar': 'المرسلات',
  },
  'An-Naba': {
    'fr': 'An-Naba',
    'en': 'An-Naba',
    'ar': 'النبأ',
  },
  'An-Nazi\'at': {
    'fr': 'An-Nazi\'at',
    'en': 'An-Nazi\'at',
    'ar': 'النازعات',
  },
  'Abasa': {
    'fr': 'Abasa',
    'en': 'Abasa',
    'ar': 'عبس',
  },
  'At-Takwir': {
    'fr': 'At-Takwir',
    'en': 'At-Takwir',
    'ar': 'التكوير',
  },
  'Al-Infitar': {
    'fr': 'Al-Infitar',
    'en': 'Al-Infitar',
    'ar': 'الإنفطار',
  },
  'Al-Mutaffifin': {
    'fr': 'Al-Mutaffifin',
    'en': 'Al-Mutaffifin',
    'ar': 'المطففين',
  },
  'Al-Inshiqaq': {
    'fr': 'Al-Inshiqaq',
    'en': 'Al-Inshiqaq',
    'ar': 'الإنشقاق',
  },
  'Al-Buruj': {
    'fr': 'Al-Buruj',
    'en': 'Al-Buruj',
    'ar': 'البروج',
  },
  'At-Tariq': {
    'fr': 'At-Tariq',
    'en': 'At-Tariq',
    'ar': 'الطارق',
  },
  'Al-A\'la': {
    'fr': 'Al-A\'la',
    'en': 'Al-A\'la',
    'ar': 'الأعلى',
  },
  'Al-Ghashiya': {
    'fr': 'Al-Ghashiya',
    'en': 'Al-Ghashiya',
    'ar': 'الغاشية',
  },
  'Al-Fajr': {
    'fr': 'Al-Fajr',
    'en': 'Al-Fajr',
    'ar': 'الفجر',
  },
  'Al-Balad': {
    'fr': 'Al-Balad',
    'en': 'Al-Balad',
    'ar': 'البلد',
  },
  'Ash-Shams': {
    'fr': 'Ash-Shams',
    'en': 'Ash-Shams',
    'ar': 'الشمس',
  },
  'Al-Layl': {
    'fr': 'Al-Layl',
    'en': 'Al-Layl',
    'ar': 'الليل',
  },
  'Ad-Duha': {
    'fr': 'Ad-Duha',
    'en': 'Ad-Duha',
    'ar': 'الضحى',
  },
  'Ash-Sharh': {
    'fr': 'Ash-Sharh',
    'en': 'Ash-Sharh',
    'ar': 'الشرح',
  },
  'At-Tin': {
    'fr': 'At-Tin',
    'en': 'At-Tin',
    'ar': 'التين',
  },
  'Al-Alaq': {
    'fr': 'Al-Alaq',
    'en': 'Al-Alaq',
    'ar': 'العلق',
  },
  'Al-Qadr': {
    'fr': 'Al-Qadr',
    'en': 'Al-Qadr',
    'ar': 'القدر',
  },
  'Al-Bayyina': {
    'fr': 'Al-Bayyina',
    'en': 'Al-Bayyina',
    'ar': 'البينة',
  },
  'Az-Zalzala': {
    'fr': 'Az-Zalzala',
    'en': 'Az-Zalzala',
    'ar': 'الزلزلة',
  },
  'Al-Adiyat': {
    'fr': 'Al-Adiyat',
    'en': 'Al-Adiyat',
    'ar': 'العاديات',
  },
  'Al-Qari\'a': {
    'fr': 'Al-Qari\'a',
    'en': 'Al-Qari\'a',
    'ar': 'القارعة',
  },
  'At-Takathur': {
    'fr': 'At-Takathur',
    'en': 'At-Takathur',
    'ar': 'التكاثر',
  },
  'Al-Asr': {
    'fr': 'Al-Asr',
    'en': 'Al-Asr',
    'ar': 'العصر',
  },
  'Al-Humaza': {
    'fr': 'Al-Humaza',
    'en': 'Al-Humaza',
    'ar': 'الهمزة',
  },
  'Al-Fil': {
    'fr': 'Al-Fil',
    'en': 'Al-Fil',
    'ar': 'الفيل',
  },
  'Quraysh': {
    'fr': 'Quraysh',
    'en': 'Quraysh',
    'ar': 'قريش',
  },
  'Al-Ma\'un': {
    'fr': 'Al-Ma\'un',
    'en': 'Al-Ma\'un',
    'ar': 'الماعون',
  },
  'Al-Kawthar': {
    'fr': 'Al-Kawthar',
    'en': 'Al-Kawthar',
    'ar': 'الكوثر',
  },
  'Al-Kafirun': {
    'fr': 'Al-Kafirun',
    'en': 'Al-Kafirun',
    'ar': 'الكافرون',
  },
  'An-Nasr': {
    'fr': 'An-Nasr',
    'en': 'An-Nasr',
    'ar': 'النصر',
  },
  'Al-Masad': {
    'fr': 'Al-Masad',
    'en': 'Al-Masad',
    'ar': 'المسد',
  },
  'Al-Ikhlas': {
    'fr': 'Al-Ikhlas',
    'en': 'Al-Ikhlas',
    'ar': 'الإخلاص',
  },
  'Al-Falaq': {
    'fr': 'Al-Falaq',
    'en': 'Al-Falaq',
    'ar': 'الفلق',
  },
  'An-Nas': {
    'fr': 'An-Nas',
    'en': 'An-Nas',
    'ar': 'الناس',
  },

  // ═══════════════════════════════════════════════════════════════
  //  QURAN - COMMON TEXTS
  // ═══════════════════════════════════════════════════════════════
  'In the name of Allah, the Most Gracious, the Most Merciful': {
    'fr': 'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux',
    'en': 'In the name of Allah, the Most Gracious, the Most Merciful',
    'ar': 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
  },
  'Say': {
    'fr': 'Dis',
    'en': 'Say',
    'ar': 'قُل',
  },
  'verse': {
    'fr': 'verset',
    'en': 'verse',
    'ar': 'آية',
  },
  'Meccan': {
    'fr': 'Mecquoise',
    'en': 'Meccan',
    'ar': 'مكية',
  },
  'Medinan': {
    'fr': 'Médinoise',
    'en': 'Medinan',
    'ar': 'مدنية',
  },
  'revelation type': {
    'fr': 'type de révélation',
    'en': 'revelation type',
    'ar': 'نوع الوحي',
  },
  'Change': {
    'fr': 'Changer',
    'en': 'Change',
    'ar': 'تغيير',
  },
  'Locating': {
    'fr': 'Localisation en cours',
    'en': 'Locating',
    'ar': 'جاري التحديد',
  },
  'Getting GPS position': {
    'fr': 'Récupération de la position GPS',
    'en': 'Getting GPS position',
    'ar': 'الحصول على موقع GPS',
  },
  'Search city...': {
    'fr': 'Rechercher une ville...',
    'en': 'Search city...',
    'ar': 'بحث عن مدينة...',
  },
  'No city found': {
    'fr': 'Aucune ville trouvée',
    'en': 'No city found',
    'ar': 'لم يتم العثور على مدينة',
  },
  'Next Prayer': {
    'fr': 'Prochaine prière',
    'en': 'Next Prayer',
    'ar': 'الصلاة القادمة',
  },
  'Hijri': {
    'fr': 'Hégire',
    'en': 'Hijri',
    'ar': 'هجري',
  },
  'Gregorian': {
    'fr': 'Grégorien',
    'en': 'Gregorian',
    'ar': 'ميلادي',
  },
  'Confirm': {
    'fr': 'Confirmer',
    'en': 'Confirm',
    'ar': 'تأكيد',
  },
  'Traduction': {
    'fr': 'Traduction',
    'en': 'Translation',
    'ar': 'ترجمة',
  },

  // ═══════════════════════════════════════════════════════════════
  //  TERMS OF SERVICE
  // ═══════════════════════════════════════════════════════════════
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
    'ar': 'تخضع هذه الشروط للقوانين السارية. يتم提交 أي نزاعات للمحاكم المختصة.',
  },
  'contact': {
    'fr': 'Contact',
    'en': 'Contact Information',
    'ar': 'معلومات الاتصال',
  },
  'contactInfo': {
    'fr': 'Pour toute question concernant ces conditions, contactez-nous :\n\n📧 Email : mindcom2018@gmail.com\n📞 Téléphone : +212 6 93 93 62 71',
    'en': 'For any questions regarding these terms, contact us:\n\n📧 Email: mindcom2018@gmail.com\n📞 Phone: +212 6 93 93 62 71',
    'ar': 'لأي أسئلة تتعلق بهذه الشروط، اتصل بنا:\n\n📧 البريد الإلكتروني: [البريد_الإلكتروني_هنا]\n📬 العنوان: [العنوان_هنا]',
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

  // ═══════════════════════════════════════════════════════════════
  //  PRIVACY POLICY
  // ═══════════════════════════════════════════════════════════════
  'privacyLastUpdated': {
    'fr': 'Dernière mise à jour : 10 mars 2026',
    'en': 'Last updated: March 10, 2026',
    'ar': 'آخر تحديث: 10 مارس 2026',
  },
  'privacySummaryTitle': {
    'fr': 'En résumé',
    'en': 'In summary',
    'ar': 'ملخص',
  },
  'privacySummaryContent': {
    'fr': 'Cette application ne collecte AUCUNE donnée personnelle.',
    'en': 'This application does NOT collect ANY personal data.',
    'ar': 'هذا التطبيق لا يجمع أي بيانات شخصية.',
  },
  'privacyIntroduction': {
    'fr': 'Introduction',
    'en': 'Introduction',
    'ar': 'مقدمة',
  },
  'privacyIntroContent': {
    'fr': 'Bienvenue sur Houda Al Fourquan. Cette politique de confidentialité explique comment nous traitons vos données. Notre engagement : Votre vie privée est notre priorité. Nous avons conçu cette application pour fonctionner avec un minimum de données et un maximum de confidentialité.',
    'en': 'Welcome to Houda Al Fourquan. This privacy policy explains how we process your data. Our commitment: Your privacy is our priority. We designed this application to work with minimum data and maximum privacy.',
    'ar': 'مرحبًا بكم في تطبيق Houda Al Fourquan. توضح سياسة الخصوصية هذه كيفية معالجة بياناتنا. التزامنا: خصوصيتك هي أولويتنا. لقد صممنا هذا التطبيق ليعمل بأقل قدر من البيانات وبأقصى قدر من الخصوصية.',
  },
  'privacyDataCollected': {
    'fr': 'Données Collectées',
    'en': 'Data Collected',
    'ar': 'البيانات المجمعة',
  },
  'privacyDataNotCollected': {
    'fr': '❌ Données NON collectées',
    'en': '❌ Data NOT Collected',
    'ar': '❌ البيانات غير المجمعة',
  },
  'privacyDataNotCollectedContent': {
    'fr': 'Nous ne collectons AUCUNE des données suivantes : nom, email, téléphone, adresse, historique de navigation, identifiants publicitaires, données de paiement.',
    'en': 'We do NOT collect any of the following: name, email, phone, address, browsing history, advertising identifiers, payment data.',
    'ar': 'نحن لا نجمع أيًا من البيانات التالية: الاسم أو البريد الإلكتروني أو الهاتف أو العنوان أو سجل التصفح أو معرفات الإعلانات أو بيانات الدفع.',
  },
  'privacyDataUsedLocally': {
    'fr': '✅ Données utilisées localement',
    'en': '✅ Data Used Locally',
    'ar': '✅ البيانات المستخدمة محليًا',
  },
  'privacyDataUsedLocallyContent': {
    'fr': 'Les données suivantes sont utilisées UNIQUEMENT sur votre appareil et ne sont JAMAIS transmises : Position GPS (pour les horaires de prière et la Qibla), Préférences utilisateur, Historique de lecture, Compteurs Tasbih.',
    'en': 'The following data is used ONLY on your device and is NEVER transmitted: GPS location (for prayer times and Qibla), User preferences, Reading history, Tasbih counters.',
    'ar': 'البيانات التالية تُستخدم فقط على جهازك ولا تُرسل أبدًا: موقع GPS (لأوقات الصلاة والقبلة)، تفضيلات المستخدم، سجل القراءة، عدادات التسبيح.',
  },
  'privacyPermissions': {
    'fr': 'Permissions Utilisées',
    'en': 'Permissions Used',
    'ar': 'الأذونات المستخدمة',
  },
  'privacyLocationTitle': {
    'fr': '📍 Localisation (GPS)',
    'en': '📍 Location (GPS)',
    'ar': '📍 الموقع (GPS)',
  },
  'privacyLocationWhy': {
    'fr': 'Calcul précis des horaires de prière et de la direction Qibla',
    'en': 'Accurate calculation of prayer times and Qibla direction',
    'ar': 'الحساب الدقيق لأوقات الصلاة واتجاه القبلة',
  },
  'privacyLocationHow': {
    'fr': 'La position est utilisée uniquement pendant l\'utilisation. Elle n\'est pas stockée.',
    'en': 'Location is used only during app usage. It is not stored.',
    'ar': 'يُستخدم الموقع فقط أثناء استخدام التطبيق. لا يتم تخزينه.',
  },
  'privacyInternetTitle': {
    'fr': '🌐 Internet',
    'en': '🌐 Internet',
    'ar': '🌐 الإنترنت',
  },
  'privacyInternetWhy': {
    'fr': 'Télécharger les récitations audio du Coran et les traductions',
    'en': 'Download Quran audio recitations and translations',
    'ar': 'تنزيل تلاوات القرآن الصوتية والترجمات',
  },
  'privacyInternetHow': {
    'fr': 'Connexion uniquement lors du téléchargement. Aucune donnée n\'est envoyée.',
    'en': 'Connection only during download. No data is sent.',
    'ar': 'الاتصال فقط أثناء التنزيل. لا يتم إرسال أي بيانات.',
  },
  'privacyNotificationsTitle': {
    'fr': '🔔 Notifications',
    'en': '🔔 Notifications',
    'ar': '🔔 الإشعارات',
  },
  'privacyNotificationsWhy': {
    'fr': 'Rappels pour les prières et l\'Adhan',
    'en': 'Reminders for prayers and Adhan',
    'ar': 'تذكيرات للصلاة والأذان',
  },
  'privacyNotificationsHow': {
    'fr': 'Notifications locales programmées sur votre appareil.',
    'en': 'Local notifications scheduled on your device.',
    'ar': 'إشعارات محلية مجدولة على جهازك.',
  },
  'privacyWhy': {
    'fr': 'Pourquoi ?',
    'en': 'Why?',
    'ar': 'لماذا؟',
  },
  'privacyHow': {
    'fr': 'Comment ?',
    'en': 'How?',
    'ar': 'كيف؟',
  },
  'privacyDataSharing': {
    'fr': 'Partage de Données',
    'en': 'Data Sharing',
    'ar': 'مشاركة البيانات',
  },
  'privacyDataSharingContent': {
    'fr': 'Nous ne vendons, ne louons et ne partageons AUCUNE donnée avec des tiers. Il n\'y a : pas de publicité, pas de analytics, pas de réseaux sociaux intégrés, pas de vente de données.',
    'en': 'We do NOT sell, rent, or share ANY data with third parties. There is: no advertising, no analytics, no social media integration, no data selling.',
    'ar': 'نحن لا نبيع أو نؤجر أو نشارك أي بيانات مع أطراف ثالثة. لا يوجد: إعلانات أو تحليلات أو تكامل مع وسائل التواصل الاجتماعي أو بيع بيانات.',
  },
  'privacyThirdParty': {
    'fr': 'Services Tiers',
    'en': 'Third-Party Services',
    'ar': 'خدمات الطرف الثالث',
  },
  'privacyThirdPartyContent': {
    'fr': 'L\'application utilise : Quran.com API (texte du Coran), EveryAyah.com (récitations audio), OpenStreetMap Nominatim (géolocalisation). Ces services reçoivent uniquement des coordonnées GPS anonymes.',
    'en': 'The application uses: Quran.com API (Quran text), EveryAyah.com (audio recitations), OpenStreetMap Nominatim (geolocation). These services receive only anonymous GPS coordinates.',
    'ar': 'يستخدم التطبيق: Quran.com API (نص القرآن)، EveryAyah.com (التلاوات الصوتية)، OpenStreetMap Nominatim (تحديد الموقع). تتلقى هذه الخدمات فقط إحداثيات GPS مجهولة.',
  },
  'privacyDataStorage': {
    'fr': 'Stockage des Données',
    'en': 'Data Storage',
    'ar': 'تخزين البيانات',
  },
  'privacyStorageWhere': {
    'fr': 'Où sont stockées vos données ?',
    'en': 'Where is your data stored?',
    'ar': 'أين تُخزن بياناتك؟',
  },
  'privacyStorageWhereContent': {
    'fr': 'Toutes vos données sont stockées localement sur votre appareil (iPhone/iPad ou Android).',
    'en': 'All your data is stored locally on your device (iPhone/iPad or Android).',
    'ar': 'جميع بياناتك تُخزن محليًا على جهازك (iPhone/iPad أو Android).',
  },
  'privacyStorageHowLong': {
    'fr': 'Combien de temps ?',
    'en': 'How long?',
    'ar': 'كم المدة؟',
  },
  'privacyStorageHowLongContent': {
    'fr': 'Les données sont conservées tant que l\'application est installée. Si vous désinstallez l\'application, toutes les données sont supprimées automatiquement.',
    'en': 'Data is retained as long as the app is installed. If you uninstall the app, all data is automatically deleted.',
    'ar': 'تُحتفظ بالبيانات طالما التطبيق مثبت. إذا قمت بإلغاء تثبيت التطبيق، تُحذف جميع البيانات تلقائيًا.',
  },
  'privacySecurity': {
    'fr': 'Sécurité',
    'en': 'Security',
    'ar': 'الأمان',
  },
  'privacySecurityContent': {
    'fr': 'Les données locales sont stockées dans le sandbox de l\'application. Aucune transmission réseau de données personnelles. Connexions HTTPS sécurisées pour le téléchargement.',
    'en': 'Local data is stored in the app sandbox. No network transmission of personal data. Secure HTTPS connections for downloads.',
    'ar': 'تُخزن البيانات المحلية في بيئة التطبيق المعزولة. لا يوجد نقل شبكي للبيانات الشخصية. اتصالات HTTPS آمنة للتنزيلات.',
  },
  'privacyUserRights': {
    'fr': 'Droits des Utilisateurs',
    'en': 'User Rights',
    'ar': 'حقوق المستخدم',
  },
  'privacyUserRightsContent': {
    'fr': 'Conformément au RGPD : Droit d\'accès (voir vos données), Droit à la suppression (désinstaller l\'app), Droit à la portabilité (non applicable), Droit d\'opposition (désactiver la localisation).',
    'en': 'Under GDPR: Right to access (view your data), Right to deletion (uninstall app), Right to portability (not applicable), Right to object (disable location).',
    'ar': 'وفقًا لـ GDPR: حق الوصول (عرض بياناتك)، حق الحذف (إلغاء تثبيت التطبيق)، حق النقل (غير منطبق)، حق الاعتراض (تعطيل الموقع).',
  },
  'privacyChildren': {
    'fr': 'Enfants et Vie Privée',
    'en': 'Children and Privacy',
    'ar': 'الأطفال والخصوصية',
  },
  'privacyChildrenContent': {
    'fr': 'Notre application : Ne collecte aucune donnée personnelle, Ne cible pas les enfants de moins de 13 ans, Est conforme avec la loi COPPA. Les enfants peuvent utiliser l\'application en toute sécurité.',
    'en': 'Our application: Does not collect any personal data, Does not target children under 13, Is COPPA compliant. Children can use the app safely.',
    'ar': 'تطبيقنا: لا يجمع أي بيانات شخصية، لا يستهدف الأطفال دون 13 عامًا، متوافق مع قانون COPPA. يمكن للأطفال استخدام التطبيق بأمان.',
  },
  'privacyChanges': {
    'fr': 'Modifications de cette Politique',
    'en': 'Changes to this Policy',
    'ar': 'تعديلات هذه السياسة',
  },
  'privacyChangesContent': {
    'fr': 'Nous pouvons mettre à jour cette politique. La date de "Dernière mise à jour" indiquera la date de la dernière modification. Nous vous encourageons à consulter régulièrement cette page.',
    'en': 'We may update this policy. The "Last updated" date will indicate the date of the last modification. We encourage you to review this page regularly.',
    'ar': 'قد نقوم بتحديث هذه السياسة. سيُشير تاريخ "آخر تحديث" إلى تاريخ آخر تعديل. نشجعك على مراجعة هذه الصفحة بانتظام.',
  },
  'privacyContact': {
    'fr': 'Contact',
    'en': 'Contact',
    'ar': 'اتصل',
  },
  'privacyContactContent': {
    'fr': 'Si vous avez des questions concernant cette politique, contactez-nous :\n\n📧 Email : mindcom2018@gmail.com\n📞 Téléphone : +212 6 93 93 62 71',
    'en': 'If you have questions about this policy, contact us:\n\n📧 Email: mindcom2018@gmail.com\n📞 Phone: +212 6 93 93 62 71',
    'ar': 'إذا كانت لديك أسئلة حول هذه السياسة، اتصل بنا:\n\n📧 البريد الإلكتروني: mindcom2018@gmail.com\n📞 الهاتف: +212 6 93 93 62 71',
  },
  'privacyFooterTitle': {
    'fr': 'Résumé en une phrase',
    'en': 'Summary in one sentence',
    'ar': 'ملخص في جملة واحدة',
  },
  'privacyFooterContent': {
    'fr': 'Houda Al Fourquan ne collecte ni ne stocke de données personnelles sur nos serveurs. Les données techniques nécessaires (GPS/IP) sont utilisées uniquement pour fournir le service.',
    'en': 'Houda Al Fourquan does not collect or store personal data on our servers. Necessary technical data (GPS/IP) is used only to provide the service.',
    'ar': 'تطبيق Houda Al Fourquan لا يجمع ولا يخزن بيانات شخصية على خوادمنا. تُستخدم بيانات تقنية لازمة (GPS/IP) فقط لتقديم الخدمة.',
  },
  'privacyFooterDate': {
    'fr': 'Cette politique de confidentialité a été créée le 10 mars 2026.',
    'en': 'This privacy policy was created on March 10, 2026.',
    'ar': 'تم إنشاء سياسة الخصوصية هذه في 10 مارس 2026.',
  },
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
};
