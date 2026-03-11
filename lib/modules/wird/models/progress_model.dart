/// Model for user reading progress
class ProgressModel {
  final int lastSurah;
  final int lastAyah;
  final int dailyGoal;
  final String? lastReadDate;
  final String? reminderTime;
  final List<String> completedDates;

  ProgressModel({
    this.lastSurah = 1,
    this.lastAyah = 0,
    this.dailyGoal = 20,
    this.lastReadDate,
    this.reminderTime = '21:00',
    this.completedDates = const [],
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      lastSurah: json['last_surah'] as int? ?? 1,
      lastAyah: json['last_ayah'] as int? ?? 0,
      dailyGoal: json['daily_goal'] as int? ?? 20,
      lastReadDate: json['last_read_date'] as String?,
      reminderTime: json['reminder_time'] as String? ?? '21:00',
      completedDates: (json['completed_dates'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_surah': lastSurah,
      'last_ayah': lastAyah,
      'daily_goal': dailyGoal,
      'last_read_date': lastReadDate,
      'reminder_time': reminderTime,
      'completed_dates': completedDates,
    };
  }

  ProgressModel copyWith({
    int? lastSurah,
    int? lastAyah,
    int? dailyGoal,
    String? lastReadDate,
    String? reminderTime,
    List<String>? completedDates,
  }) {
    return ProgressModel(
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyah: lastAyah ?? this.lastAyah,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      reminderTime: reminderTime ?? this.reminderTime,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  /// Check if user already read today
  bool hasReadToday() {
    if (lastReadDate == null) return false;
    final today = DateTime.now();
    final lastDate = DateTime.parse(lastReadDate!);
    return today.year == lastDate.year &&
        today.month == lastDate.month &&
        today.day == lastDate.day;
  }

  /// Get today's date as string (YYYY-MM-DD)
  static String getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Check if date is today
  static bool isToday(String dateString) {
    final date = DateTime.parse(dateString);
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }
}
