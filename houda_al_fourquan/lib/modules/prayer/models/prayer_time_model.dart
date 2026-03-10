import 'package:adhan_dart/adhan_dart.dart';

/// Prayer Time Model
class PrayerTimeModel {
  final String name;
  final DateTime? time;
  final Prayer? prayer;
  final bool isNext;
  final bool isCurrent;

  PrayerTimeModel({
    required this.name,
    this.time,
    this.prayer,
    this.isNext = false,
    this.isCurrent = false,
  });

  /// Get formatted time string (HH:mm)
  String get formattedTime {
    if (time == null) return '--:--';
    return '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
  }

  /// Get display name (localized)
  String get displayName {
    switch (name.toLowerCase()) {
      case 'fajr':
        return 'Fajr';
      case 'sunrise':
        return 'Sunrise';
      case 'dhuhr':
        return 'Dhuhr';
      case 'asr':
        return 'Asr';
      case 'maghrib':
        return 'Maghrib';
      case 'isha':
        return 'Isha';
      default:
        return name;
    }
  }

  /// Get Arabic name
  String get arabicName {
    switch (name.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'sunrise':
        return 'الشروق';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return '';
    }
  }
}

/// Prayer Day Model
class PrayerDayModel {
  final DateTime date;
  final List<PrayerTimeModel> prayers;
  final String? hijriDate;

  PrayerDayModel({required this.date, required this.prayers, this.hijriDate});
}
