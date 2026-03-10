import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../core/controllers/theme_controller.dart';
import '../controller/home_controller.dart';
import '../widgets/city_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/next_prayer_widget.dart';
import '../widgets/prayer_times_widget.dart';
import '../widgets/menu_cards_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    final ThemeController themeController = Get.put(ThemeController());

    return Scaffold(
      backgroundColor: DT.bg(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: DT.bg(context),
            border: Border(
              bottom: BorderSide(color: DT.borderColor(context), width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Logo à gauche
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: DT.accentGrad(context),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: DT.accent(context).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/logo.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.nights_stay_rounded,
                            color: DT.blanc,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Titre
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salat'.trx,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DT
                              .titleLg(context)
                              .copyWith(fontSize: 18, height: 1.1, color: DT.txt(context)),
                        ),
                        Text(
                          'Prayer Times'.trx,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DT.sub(context).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // Language Switcher stylisé
                  GetBuilder<LanguageController>(
                    builder: (controller) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: DT.glass(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: DT.borderColor(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.currentLang,

                            dropdownColor: DT.bg(context),
                            style: DT.titleMd(context).copyWith(fontSize: 12, letterSpacing: 0.6),
                            items: [
                              DropdownMenuItem(
                                value: 'fr',
                                child: const Text('FR'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: const Text('EN'),
                              ),
                              DropdownMenuItem(
                                value: 'ar',
                                child: const Text('AR'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.setLanguage(value);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  // Theme Switcher stylisé
                  Obx(
                    () => Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: DT.glass(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: DT.borderColor(context)),
                      ),
                      child: IconButton(
                        icon: Icon(
                          themeController.isDarkMode.value
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: DT.accent(context),
                          size: 22,
                        ),
                        onPressed: () => themeController.toggleTheme(),
                        tooltip: themeController.isDarkMode.value
                            ? 'Mode clair'.trx
                            : 'Mode sombre'.trx,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // City Widget (Position)
              const CityWidget(),
              const SizedBox(height: 8),
              // Calendar Widget
              const CalendarWidget(),
              const SizedBox(height: 8),
              // Next Prayer Widget
              const NextPrayerWidget(),
              const SizedBox(height: 8),
              // Prayer Times Widget
              const PrayerTimesWidget(),
              const SizedBox(height: 8),
              // Menu Cards Widget
              const MenuCardsWidget(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
