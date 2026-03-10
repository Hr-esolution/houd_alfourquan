class Ayah {
  final int number;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String? audioUrl;
  final int? juz;
  final int? hizb;
  final int? rub;

  Ayah({
    required this.number,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.audioUrl,
    this.juz,
    this.hizb,
    this.rub,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number:
          json['number'] ??
          ((json['surahNumber'] ?? 0) * 1000 + (json['ayahNumber'] ?? 0)),
      surahNumber: json['surahNumber'] ?? json['chapter'] ?? 1,
      ayahNumber: json['ayahNumber'] ?? json['verse'] ?? 1,
      text: json['text'] ?? '',
      audioUrl: json['audioUrl'],
      juz: json['juz'],
      hizb: json['hizb'],
      rub: json['rub'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'text': text,
      'audioUrl': audioUrl,
      'juz': juz,
      'hizb': hizb,
      'rub': rub,
    };
  }

  String get uniqueId => '$surahNumber:$ayahNumber';
}
