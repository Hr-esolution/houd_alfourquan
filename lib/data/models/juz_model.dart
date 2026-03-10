class Juz {
  final int number;
  final String name;
  final int firstSurahNumber;
  final int firstAyahNumber;

  Juz({
    required this.number,
    required this.name,
    required this.firstSurahNumber,
    required this.firstAyahNumber,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      number: json['number'],
      name: json['name'] ?? 'Juz ${json['number']}',
      firstSurahNumber: json['firstSurahNumber'],
      firstAyahNumber: json['firstAyahNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'firstSurahNumber': firstSurahNumber,
      'firstAyahNumber': firstAyahNumber,
    };
  }
}

class Page {
  final int number;
  final int firstSurahNumber;
  final int firstAyahNumber;

  Page({
    required this.number,
    required this.firstSurahNumber,
    required this.firstAyahNumber,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      number: json['number'],
      firstSurahNumber: json['firstSurahNumber'],
      firstAyahNumber: json['firstAyahNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'firstSurahNumber': firstSurahNumber,
      'firstAyahNumber': firstAyahNumber,
    };
  }
}
