import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../controller/home_controller.dart';

class NextPrayerWidget extends GetView<HomeController> {
  const NextPrayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return GetBuilder<LanguageController>(
          builder: (langController) {
            final nextPrayer = controller.nextPrayerName;
            final countdown = controller.countdown;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DT.orDark, DT.or],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: DT.or.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DT.blanc.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: DT.blanc,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Prayer'.trx,
                          style: TextStyle(
                            color: DT.blanc.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextPrayer.isEmpty ? 'Fajr'.trx : _getPrayerNameTranslated(nextPrayer),
                          style: const TextStyle(
                            color: DT.blanc,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: DT.blanc.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      countdown.isEmpty ? '00:00:00' : countdown,
                      style: const TextStyle(
                        color: DT.blanc,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getPrayerNameTranslated(String name) {
    switch (name.toLowerCase()) {
      case 'fajr': return 'Fajr'.trx;
      case 'dhuhr': return 'Dhuhr'.trx;
      case 'asr': return 'Asr'.trx;
      case 'maghrib': return 'Maghrib'.trx;
      case 'isha': return 'Isha'.trx;
      default: return name.capitalizeFirst ?? name;
    }
  }
}
