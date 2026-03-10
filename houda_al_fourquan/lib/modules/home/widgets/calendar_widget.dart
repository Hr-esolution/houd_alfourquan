import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../controller/home_controller.dart';

class CalendarWidget extends GetView<HomeController> {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return GetBuilder<LanguageController>(
          builder: (langController) {
            return Glass(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDateColumn(
                    controller.hijriDate,
                    'Hijri'.trx,
                    Icons.nights_stay,
                    context,
                  ),
                  Container(
                    height: 35,
                    width: 1,
                    color: DT.or.withValues(alpha: 0.2),
                  ),
                  _buildDateColumn(
                    controller.gregorianDate,
                    'Gregorian'.trx,
                    Icons.today,
                    context,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateColumn(String date, String label, IconData icon, BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: DT.or.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DT.or, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          date.isEmpty ? '--' : date,
          style: DT.titleMd(context),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: DT.sub(context),
        ),
      ],
    );
  }
}
