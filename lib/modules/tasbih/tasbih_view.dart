import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/controllers/language_controller.dart';
import '../../core/widgets/language_switcher.dart';
import 'tasbih_controller.dart';
import 'model/tasbih_item.dart';

/// Tasbih View - Compact & Harmonized (layout only)
class TasbihView extends StatelessWidget {
  const TasbihView({super.key});

  @override
  Widget build(BuildContext context) {
    final TasbihController controller = Get.find<TasbihController>();

    return Scaffold(
      backgroundColor: DT.bg(context),
      appBar: AppBar(
        title: Text('Tasbih'.trx, style: DT.titleLg(context)),
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
        actions: [
          const LanguageSwitcher(),
          IconButton(
            icon: const Icon(Icons.history, color: DT.blanc),
            onPressed: () => _showHistory(context, controller),
            tooltip: 'History'.trx,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: DT.blanc),
            onPressed: () => _showSettings(context, controller),
            tooltip: 'Settings'.trx,
          ),
        ],
      ),
      body: GetBuilder<TasbihController>(
        builder: (ctrl) {
          if (!ctrl.isInitialized.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentTasbih = ctrl.selectedTasbih.value;
          if (currentTasbih == null) {
            return Center(child: Text('No tasbih selected'.trx));
          }

          final progress = ctrl.counter.value / currentTasbih.targetCount;

          return GetBuilder<LanguageController>(
            builder: (langController) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // ── Arabic Text Card ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: DT.accentGrad(context),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: DT.accent(context).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentTasbih.arabicText,
                            style: const TextStyle(
                              fontSize: 26,
                              fontFamily: 'Amiri',
                              color: DT.blanc,
                              height: 1.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (!langController.isArabic) ...[
                            const SizedBox(height: 6),
                            Text(
                              currentTasbih.translatedText,
                              style: const TextStyle(
                                fontSize: 15,
                                color: DT.blanc,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: DT.blanc.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${'Target'.trx}: ${currentTasbih.targetCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: DT.blanc,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Counter + Buttons (same row, centered) ────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Reset button — left
                        _CircleAction(
                          size: 44,
                          icon: Icons.refresh,
                          iconSize: 20,
                          context: context,
                          onTap: () => ctrl.reset(),
                          tooltip: 'Reset'.trx,
                        ),
                        const SizedBox(width: 20),

                        // Counter circle — center
                        GestureDetector(
                          onTap: () => ctrl.increment(),
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: DT.accentGrad(context),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: DT
                                      .accent(context)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 152,
                                  height: 152,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 4,
                                    backgroundColor: DT.blanc.withValues(
                                      alpha: 0.2,
                                    ),
                                    valueColor: AlwaysStoppedAnimation(
                                      DT.blanc,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${ctrl.counter.value}',
                                      style: const TextStyle(
                                        fontSize: 46,
                                        fontWeight: FontWeight.bold,
                                        color: DT.blanc,
                                      ),
                                    ),
                                    Text(
                                      '/ ${currentTasbih.targetCount}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: DT.blanc,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Add button — right
                        _CircleAction(
                          size: 56,
                          icon: Icons.add,
                          iconSize: 28,
                          context: context,
                          onTap: () => ctrl.increment(),
                          tooltip: 'Count'.trx,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Presets List ──────────────────────────────────────
                    Glass(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Presets'.trx,
                              style: DT.label(context),
                            ),
                          ),
                          ...ctrl.presets.map(
                            (preset) => _TasbihListItem(
                              preset: preset,
                              count: ctrl.getTasbihCount(preset.id),
                              target: preset.targetCount,
                              isSelected:
                                  ctrl.selectedTasbih.value?.id == preset.id,
                              onTap: () => ctrl.selectTasbih(preset),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showHistory(BuildContext context, TasbihController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: DT.bg(context),
        title: Text('History'.trx, style: DT.titleMd(context)),
        content: Obx(
          () => Text(
            'Total: ${controller.allCounts.values.fold<int>(0, (sum, count) => sum + count)} counts',
            style: DT.sub(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'.trx, style: DT.sub(context)),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, TasbihController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: DT.bg(context),
        title: Text('Settings'.trx, style: DT.titleMd(context)),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [33, 99, 100, 500, 1000].map((target) {
              final isSelected =
                  controller.selectedTasbih.value?.targetCount == target;
              return ChoiceChip(
                label: Text('$target'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected && controller.selectedTasbih.value != null) {
                    final updated = TasbihItem(
                      id: controller.selectedTasbih.value!.id,
                      frenchText: controller.selectedTasbih.value!.frenchText,
                      arabicText: controller.selectedTasbih.value!.arabicText,
                      targetCount: target,
                      transliteration:
                          controller.selectedTasbih.value!.transliteration,
                    );
                    controller.selectTasbih(updated);
                  }
                },
                selectedColor: DT.accent(context),
                labelStyle: TextStyle(
                  color: isSelected ? DT.blanc : DT.txt(context),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'.trx, style: DT.sub(context)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable circular action button ──────────────────────────────────────────
class _CircleAction extends StatelessWidget {
  final double size;
  final IconData icon;
  final double iconSize;
  final BuildContext context;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleAction({
    required this.size,
    required this.icon,
    required this.iconSize,
    required this.context,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext ctx) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: DT.accentGrad(context)),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DT.accent(context).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: DT.blanc, size: iconSize),
        ),
      ),
    );
  }
}

// ── Tasbih List Item ──────────────────────────────────────────────────────────
class _TasbihListItem extends StatelessWidget {
  final TasbihItem preset;
  final int count;
  final int target;
  final bool isSelected;
  final VoidCallback onTap;

  const _TasbihListItem({
    required this.preset,
    required this.count,
    required this.target,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (langController) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? DT.accent(context).withValues(alpha: 0.1)
                  : DT.glass(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? DT.accent(context)
                    : DT.borderColor(context),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(preset.translatedText, style: DT.titleMd(context)),
                      const SizedBox(height: 2),
                      Text('$count / $target', style: DT.sub(context)),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: DT.accent(context), size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
