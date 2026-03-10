import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../core/utils/date_utils.dart';
import '../../prayer/controllers/adhan_controller.dart';
import '../controller/home_controller.dart';

class PrayerTimesWidget extends GetView<HomeController> {
  const PrayerTimesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdhanController>()) {
      Get.put(AdhanController(), permanent: true);
    }

    final AdhanController adhanController = Get.find<AdhanController>();

    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.prayerTimes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(DT.or),
            ),
          );
        }

        return GetBuilder<LanguageController>(
          builder: (langController) {
            return Glass(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: DT.or.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: DT.or,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Prayer Times'.trx,
                        style: DT.titleMd(context).copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPrayerRow(context, 'fajr', controller.prayerTimes['fajr'], adhanController),
                  _buildPrayerRow(context, 'dhuhr', controller.prayerTimes['dhuhr'], adhanController),
                  _buildPrayerRow(context, 'asr', controller.prayerTimes['asr'], adhanController),
                  _buildPrayerRow(context, 'maghrib', controller.prayerTimes['maghrib'], adhanController),
                  _buildPrayerRow(context, 'isha', controller.prayerTimes['isha'], adhanController),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrayerRow(BuildContext context, String name, DateTime? time, AdhanController adhanController) {
    final isNext = controller.nextPrayerName == name;
    final prayerName = name.toLowerCase();

    return GetBuilder<AdhanController>(
      id: 'adhan_$prayerName',
      builder: (adhanCtrl) {
        final settings = adhanCtrl.prayerSettings[prayerName];
        final isEnabled = settings?.isEnabled ?? false;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isNext ? DT.or.withValues(alpha: 0.08) : DT.divider(context),
            borderRadius: BorderRadius.circular(10),
            border: isNext
                ? Border.all(color: DT.or.withValues(alpha: 0.35), width: 1.2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => adhanCtrl.togglePrayerAdhan(prayerName),
                    onLongPress: () => Get.toNamed('/adhan-settings', arguments: prayerName),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? DT.or.withValues(alpha: 0.12)
                            : DT.subC(context).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isEnabled ? Icons.notifications_active : Icons.notifications_off,
                        color: isEnabled ? DT.or : DT.subC(context),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isNext) ...[
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: DT.or,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  Text(
                    _getPrayerNameTranslated(name),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
                      color: isNext ? DT.or : DT.subC(context),
                    ),
                  ),
                ],
              ),
              Text(
                time != null ? DateUtilsHelper.formatTime(time) : '--:--',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isNext ? DT.or : DT.txt(context),
                ),
              ),
            ],
          ),
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
