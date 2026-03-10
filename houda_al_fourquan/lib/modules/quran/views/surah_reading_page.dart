import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../controllers/reading_controller.dart';

class SurahReadingPage extends StatelessWidget {
  const SurahReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int surahNumber = Get.arguments?['surahNumber'] ?? 1;
    final String surahName = Get.arguments?['surahName'] ?? 'Al-Fatiha';
    final ReadingController controller = Get.put(ReadingController());

    controller.loadSurah(surahNumber, 'ar');

    return GetBuilder<LanguageController>(
      builder: (langController) {
        return Scaffold(
          backgroundColor: DT.bg(context),
          appBar: AppBar(
            title: Text(
              surahName.trx,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: DT.titleLg(context).copyWith(
                fontSize: 20,
                letterSpacing: 0.3,
                color: DT.dark(context) ? DT.noir : DT.blanc,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: DT.accentGrad(context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: GetBuilder<ReadingController>(
            builder: (controller) {
              if (controller.ayahs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Chargement du texte...'),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  const AyahIndicatorWidget(),
                  _ScrollControls(controller: controller, context: context),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Basmala - only for Arabic
                          if (langController.isArabic && surahNumber != 1 && surahNumber != 9)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontFamily: 'UthmanicHafs',
                                  fontSize: 24,
                                  height: 2.0,
                                ),
                              ),
                            ),
                          // Arabic text - only for Arabic language
                          if (langController.isArabic)
                            RichText(
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'UthmanicHafs',
                                  fontSize: 24,
                                  height: 1.6,
                                  fontWeight: FontWeight.normal,
                                  color: DT.txt(context),
                                ),
                                children: _buildArabicAyahSpans(
                                  controller.ayahs,
                                  context,
                                ),
                              ),
                            )
                          // Translation - for French and English
                          else if (controller.translations.isNotEmpty)
                            Text(
                              controller.translations
                                  .map((t) => t['text'] as String)
                                  .join(' '),
                              textAlign: TextAlign.left,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.5,
                                color: DT.txt(context),
                              ),
                            ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: DT.accent(context)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'End of Surah'.trx,
                              style: TextStyle(
                                fontSize: 11,
                                color: DT.accent(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<TextSpan> _buildArabicAyahSpans(
    List<Map<String, dynamic>> ayahs,
    BuildContext context,
  ) {
    final spans = <TextSpan>[];
    for (final ayah in ayahs) {
      final text = (ayah['text'] as String?) ?? '';
      final number = (ayah['number_ar'] as String?) ?? '';
      if (text.isEmpty) continue;
      spans.add(TextSpan(text: '$text '));
      if (number.isNotEmpty) {
        spans.add(
          TextSpan(
            text: '﴿$number﴾ ',
            style: TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: DT.or,
            ),
          ),
        );
      }
    }
    return spans;
  }
}

class _ScrollControls extends StatelessWidget {
  final ReadingController controller;
  final BuildContext context;

  const _ScrollControls({
    required this.controller,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReadingController>(
      id: 'scroll_controls',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: DT.glass(context),
            border: Border.all(color: DT.borderColor(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: controller.toggleScroll,
                icon: Icon(
                  controller.isScrolling ? Icons.pause : Icons.play_arrow,
                  color: DT.blanc,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: controller.isScrolling
                      ? DT.or
                      : DT.accent(context),
                  shape: const CircleBorder(),
                ),
                tooltip: controller.isScrolling ? 'Pause'.trx : 'Auto-scroll'.trx,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: controller.scrollSpeed,
                  min: 0.5,
                  max: 5.0,
                  divisions: 9,
                  label: controller.scrollSpeed.toStringAsFixed(1),
                  onChanged: controller.setSpeed,
                  activeColor: DT.accent(context),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: controller.goToBeginning,
                icon: const Icon(Icons.arrow_upward, color: DT.blanc),
                style: IconButton.styleFrom(
                  backgroundColor: DT.accent(context),
                  shape: const CircleBorder(),
                ),
                tooltip: 'Go to top'.trx,
              ),
            ],
          ),
        );
      },
    );
  }
}

class AyahIndicatorWidget extends StatelessWidget {
  const AyahIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReadingController>(
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: DT.accentGrad(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark, color: DT.blanc, size: 16),
              const SizedBox(width: 8),
              Text(
                '${controller.ayahs.length} ${'Ayahs'.trx}',
                style: const TextStyle(
                  color: DT.blanc,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
