/// Dua model representing a supplication
class DuaModel {
  final int id;
  final String category;
  final String arabic;
  final String translationFr;
  final String translationEn;
  final String translationAr;
  final String reference;
  final int repeat;

  DuaModel({
    required this.id,
    required this.category,
    required this.arabic,
    required this.translationFr,
    required this.translationEn,
    this.translationAr = '',
    this.reference = '',
    this.repeat = 1,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'] as Map<String, dynamic>;
    return DuaModel(
      id: json['id'] as int,
      category: json['category'] as String,
      arabic: json['arabic'] as String,
      translationFr: translations['fr'] as String,
      translationEn: translations['en'] as String,
      translationAr: translations['ar'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      repeat: json['repeat'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'arabic': arabic,
      'translations': {
        'fr': translationFr,
        'en': translationEn,
        'ar': translationAr,
      },
      'reference': reference,
      'repeat': repeat,
    };
  }

  /// Get translation based on current language
  String getTranslation(String langCode) {
    switch (langCode) {
      case 'ar':
        // For Arabic, return Arabic translation if available, otherwise use French
        return translationAr.isNotEmpty ? translationAr : translationFr;
      case 'en':
        return translationEn;
      case 'fr':
      default:
        return translationFr;
    }
  }

  /// Check if translation is available for language
  bool hasTranslation(String langCode) {
    switch (langCode) {
      case 'ar':
        return translationAr.isNotEmpty;
      case 'en':
        return translationEn.isNotEmpty;
      case 'fr':
        return translationFr.isNotEmpty;
      default:
        return false;
    }
  }
}
