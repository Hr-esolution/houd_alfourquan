/// Model for a single Ayah (verse)
class AyahModel {
  final int surahNumber;
  final int ayahNumber;
  final String textAr;
  final String textFr;
  final String textEn;

  AyahModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textAr,
    required this.textFr,
    required this.textEn,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json, {required int surahNumber}) {
    return AyahModel(
      surahNumber: surahNumber,
      ayahNumber: json['number'] as int,
      textAr: json['text_ar'] as String,
      textFr: json['text_fr'] as String,
      textEn: json['text_en'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'text_ar': textAr,
      'text_fr': textFr,
      'text_en': textEn,
    };
  }

  /// Get text based on language code
  String getText(String langCode) {
    switch (langCode) {
      case 'ar':
        return textAr;
      case 'en':
        return textEn;
      case 'fr':
      default:
        return textFr;
    }
  }
}
