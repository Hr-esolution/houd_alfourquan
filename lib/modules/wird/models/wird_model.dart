import 'ayah_model.dart';

/// Model for a daily Wird (portion of Quran to read)
class WirdModel {
  final String date;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final List<AyahModel> verses;
  final bool isCompleted;
  final bool isQuranComplete;

  WirdModel({
    required this.date,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.verses,
    this.isCompleted = false,
    this.isQuranComplete = false,
  });

  factory WirdModel.fromJson(Map<String, dynamic> json) {
    return WirdModel(
      date: json['date'] as String,
      startSurah: json['start_surah'] as int,
      startAyah: json['start_ayah'] as int,
      endSurah: json['end_surah'] as int,
      endAyah: json['end_ayah'] as int,
      verses: (json['verses'] as List<dynamic>)
          .map((v) => AyahModel.fromJson(
                v as Map<String, dynamic>,
                surahNumber: v['surahNumber'] as int,
              ))
          .toList(),
      isCompleted: json['is_completed'] as bool? ?? false,
      isQuranComplete: json['is_quran_complete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'start_surah': startSurah,
      'start_ayah': startAyah,
      'end_surah': endSurah,
      'end_ayah': endAyah,
      'verses': verses.map((v) => v.toJson()).toList(),
      'is_completed': isCompleted,
      'is_quran_complete': isQuranComplete,
    };
  }

  /// Get display title for the Wird
  String get title {
    if (isQuranComplete) {
      return 'Khatm - القرآن كاملاً';
    }
    return 'Wird du ${_formatDate()}';
  }

  /// Get verse count
  int get verseCount => verses.length;

  /// Format date for display based on locale
  String _formatDate() {
    try {
      final parsed = DateTime.parse(date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final wirdDate = DateTime(parsed.year, parsed.month, parsed.day);

      if (wirdDate == today) {
        return "Aujourd'hui";
      } else if (wirdDate == yesterday) {
        return 'Hier';
      } else {
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      }
    } catch (_) {
      return date;
    }
  }

  WirdModel copyWith({
    String? date,
    int? startSurah,
    int? startAyah,
    int? endSurah,
    int? endAyah,
    List<AyahModel>? verses,
    bool? isCompleted,
    bool? isQuranComplete,
  }) {
    return WirdModel(
      date: date ?? this.date,
      startSurah: startSurah ?? this.startSurah,
      startAyah: startAyah ?? this.startAyah,
      endSurah: endSurah ?? this.endSurah,
      endAyah: endAyah ?? this.endAyah,
      verses: verses ?? this.verses,
      isCompleted: isCompleted ?? this.isCompleted,
      isQuranComplete: isQuranComplete ?? this.isQuranComplete,
    );
  }
}
