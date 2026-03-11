import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../controllers/language_controller.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (controller) {
        return PopupMenuButton<String>(
          icon: Center(
            child: Icon(
              Icons.language,
              color: DT.dark(context) ? DT.or : DT.noir,
            ),
          ),
          tooltip: 'Language'.trx,
          onSelected: (value) => controller.setLanguage(value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'fr',
              child: Row(
                children: [
                  _LangFlag(code: 'fr', emoji: '🇫🇷'),
                  const SizedBox(width: 8),
                  Text('Français'.trx),
                  if (controller.currentLang == 'fr') ...[
                    const Spacer(),
                    Icon(Icons.check, color: DT.accent(context)),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: 'en',
              child: Row(
                children: [
                  _LangFlag(code: 'en', emoji: '🇬🇧'),
                  const SizedBox(width: 8),
                  Text('English'.trx),
                  if (controller.currentLang == 'en') ...[
                    const Spacer(),
                    Icon(Icons.check, color: DT.accent(context)),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: 'ar',
              child: Row(
                children: [
                  _LangFlag(code: 'ar', emoji: '🇸🇦'),
                  const SizedBox(width: 8),
                  Text('العربية'.trx),
                  if (controller.currentLang == 'ar') ...[
                    const Spacer(),
                    Icon(Icons.check, color: DT.accent(context)),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LangFlag extends StatelessWidget {
  final String code;
  final String emoji;

  const _LangFlag({required this.code, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: DT.blanc,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: DT.borderColor(context)),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
