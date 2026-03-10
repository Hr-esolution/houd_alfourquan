import 'package:get/get.dart';

class TasbihItem {
  final String id;
  final String arabicText;
  final String frenchText;
  final String englishText;
  final String transliteration;
  final int targetCount;
  final TasbihCategory category;

  TasbihItem({
    required this.id,
    required this.arabicText,
    required this.frenchText,
    this.englishText = '',
    required this.transliteration,
    this.targetCount = 100,
    this.category = TasbihCategory.daily,
  });

  /// Get translated text based on current language
  String get translatedText {
    final langCode = Get.locale?.languageCode ?? 'fr';
    switch (langCode) {
      case 'ar':
        return arabicText;
      case 'en':
        return englishText.isNotEmpty ? englishText : frenchText;
      case 'fr':
      default:
        return frenchText;
    }
  }

  /// Create a custom tasbih
  factory TasbihItem.custom({
    required String id,
    required String frenchText,
    int targetCount = 33,
  }) {
    return TasbihItem(
      id: id,
      arabicText: '',
      frenchText: frenchText,
      transliteration: '',
      targetCount: targetCount,
    );
  }
}

enum TasbihCategory {
  daily('Quotidien', 'Daily Adhkar', 'أذكار يومية'),
  afterPrayer('Après Prière', 'After Prayer', 'أذكار بعد الصلاة');

  final String frenchName;
  final String englishName;
  final String arabicName;

  const TasbihCategory(this.frenchName, this.englishName, this.arabicName);

  /// Get translated category name
  String get translatedName {
    final langCode = Get.locale?.languageCode ?? 'fr';
    switch (langCode) {
      case 'ar':
        return arabicName;
      case 'en':
        return englishName;
      case 'fr':
      default:
        return frenchName;
    }
  }
}

/// Tasbih Presets - Hisn al-Muslim
class TasbihPresets {
  /// 1️⃣ Tasbih quotidien (أذكار يومية)
  static final List<TasbihItem> daily = [
    TasbihItem(
      id: 'subhan_allah_wabihamdihi',
      arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      frenchText: 'Gloire et louange à Allah',
      englishText: 'Glory and praise be to Allah',
      transliteration: 'Subhan Allah wa bihamdihi',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'subhan_allah_al_adhim',
      arabicText: 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
      frenchText: 'Gloire à Allah l\'Immense',
      englishText: 'Glory be to Allah, the Immense',
      transliteration: 'Subhan Allah al-Azim',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'la_ilaha_illallah_wahdahu',
      arabicText:
          'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      frenchText: 'Il n\'y a de dieu qu\'Allah, unique sans associé',
      englishText: 'There is no god but Allah, alone without partner',
      transliteration: 'La ilaha illallah wahdahu la sharika lah...',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'astaghfirullah_wa_atubu',
      arabicText: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      frenchText: 'Je demande pardon à Allah et me repens',
      englishText: 'I seek forgiveness from Allah and repent to Him',
      transliteration: 'Astaghfirullah wa atubu ilayhi',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'sallallahu_ala_nabi',
      arabicText: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ',
      frenchText: 'Paix et bénédiction sur le Prophète',
      englishText: 'Peace and blessings upon our Prophet Muhammad',
      transliteration: 'Allahumma salli wa sallim ala nabiyyina Muhammad',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'alhamdulillah_rabbil_alamin',
      arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      frenchText: 'Louange à Allah, Seigneur des mondes',
      englishText: 'All praise is due to Allah, Lord of the worlds',
      transliteration: 'Alhamdulillah rabbil alamin',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'la_hawla_wala_quwwata',
      arabicText: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      frenchText: 'Nulle force ni puissance sauf par Allah',
      englishText: 'There is no power nor strength except by Allah',
      transliteration: 'La hawla wala quwwata illa billah',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'allahumma_ghfir_li',
      arabicText: 'اللَّهُمَّ اغْفِرْ لِي وَلِوَالِدَيَّ',
      frenchText: 'Ô Allah, pardonne-moi et à mes parents',
      englishText: 'O Allah, forgive me and my parents',
      transliteration: 'Allahumma ghfir li wa liwalidayya',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'allahumma_rzuqni',
      arabicText: 'اللَّهُمَّ ارْزُقْنِي مِنْ فَضْلِكَ',
      frenchText: 'Ô Allah, accorde-moi Ta subsistance',
      englishText: 'O Allah, grant me from Your provision',
      transliteration: 'Allahumma rzuqni min fadlik',
      targetCount: 100,
    ),
    TasbihItem(
      id: 'allahumma_hdini',
      arabicText: 'اللَّهُمَّ اهْدِنِي وَاهْدِ بِي',
      frenchText: 'Ô Allah, guide-moi et guide par moi',
      englishText: 'O Allah, guide me and guide through me',
      transliteration: 'Allahumma hdini wahdi bi',
      targetCount: 100,
    ),
  ];

  /// 2️⃣ Tasbih après la prière (أذكار بعد الصلاة)
  static final List<TasbihItem> afterPrayer = [
    TasbihItem(
      id: 'astaghfirullah_3x',
      arabicText: 'أَسْتَغْفِرُ اللَّهَ',
      frenchText: 'Je demande pardon à Allah (3 fois)',
      englishText: 'I seek forgiveness from Allah (3 times)',
      transliteration: 'Astaghfirullah',
      targetCount: 3,
    ),
    TasbihItem(
      id: 'allahumma_antas_salam',
      arabicText:
          'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      frenchText: 'Ô Allah, Tu es la Paix...',
      englishText: 'O Allah, You are Peace and from You is peace...',
      transliteration: 'Allahumma antas-salam wa minkas-salam...',
      targetCount: 1,
    ),
    TasbihItem(
      id: 'subhan_allah_33x',
      arabicText: 'سُبْحَانَ اللَّهِ',
      frenchText: 'Gloire à Allah (33 fois)',
      englishText: 'Glory be to Allah (33 times)',
      transliteration: 'Subhan Allah',
      targetCount: 33,
    ),
    TasbihItem(
      id: 'alhamdulillah_33x',
      arabicText: 'الْحَمْدُ لِلَّهِ',
      frenchText: 'Louange à Allah (33 fois)',
      englishText: 'All praise is due to Allah (33 times)',
      transliteration: 'Alhamdulillah',
      targetCount: 33,
    ),
    TasbihItem(
      id: 'allahu_akbar_34x',
      arabicText: 'اللَّهُ أَكْبَرُ',
      frenchText: 'Allah est le Plus Grand (34 fois)',
      englishText: 'Allah is the Greatest (34 times)',
      transliteration: 'Allahu Akbar',
      targetCount: 34,
    ),
    TasbihItem(
      id: 'la_ilaha_illallah_after_prayer',
      arabicText:
          'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      frenchText: 'Il n\'y a de dieu qu\'Allah, unique sans associé',
      englishText: 'There is no god but Allah, alone without partner',
      transliteration: 'La ilaha illallah wahdahu la sharika lah...',
      targetCount: 1,
    ),
    TasbihItem(
      id: 'allahumma_a_inni_alaa_dhikrik',
      arabicText:
          'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      frenchText: 'Ô Allah, aide-moi à T\'évoquer...',
      englishText: 'O Allah, help me to remember You...',
      transliteration: 'Allahumma a-inni ala dhikrika wa shukrika...',
      targetCount: 1,
    ),
  ];

  /// Get all presets combined
  static List<TasbihItem> get all => [...daily, ...afterPrayer];
}
