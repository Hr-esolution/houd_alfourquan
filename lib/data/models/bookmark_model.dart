class Bookmark {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final DateTime createdAt;
  final String? note;

  Bookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.createdAt,
    this.note,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      surahNumber: json['surahNumber'],
      ayahNumber: json['ayahNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  String get ayahId => '$surahNumber:$ayahNumber';
}
