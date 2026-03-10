class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['id'] ?? json['number'],
      name: json['name'],
      englishName: json['transliteration'] ?? json['englishName'],
      englishNameTranslation:
          json['translation'] ?? json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['total_verses'] ?? json['numberOfAyahs'],
      revelationType: (json['type'] ?? json['revelationType'] ?? 'meccan')
          .toString()
          .toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': number,
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
      'type': revelationType.toLowerCase(),
      'total_verses': numberOfAyahs,
    };
  }
}
