import 'package:get/get.dart';

class Reciter {
  final String identifier;
  final String name;
  final String englishName;
  final String style;
  final String baseUrl;

  Reciter({
    required this.identifier,
    required this.name,
    required this.englishName,
    required this.style,
    required this.baseUrl,
  });

  factory Reciter.fromMap(Map<String, dynamic> map) {
    return Reciter(
      identifier: map['identifier'] ?? '',
      name: map['name'] ?? '',
      englishName: map['englishName'] ?? '',
      style: map['style'] ?? 'murattal',
      baseUrl: map['baseUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'name': name,
      'englishName': englishName,
      'style': style,
      'baseUrl': baseUrl,
    };
  }

  String get id => identifier;
  String get nameAr => name;
  String get nameFr => englishName;

  // Get translated name based on current language
  String get translatedName {
    final langCode = Get.locale?.languageCode ?? 'fr';
    switch (langCode) {
      case 'ar':
        return nameAr;
      case 'en':
        return englishName;
      case 'fr':
      default:
        return englishName;
    }
  }
}
