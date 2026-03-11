import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../controllers/douaa_controller.dart';
import 'dua_list_view.dart';

class DouaaView extends StatelessWidget {
  const DouaaView({super.key});

  @override
  Widget build(BuildContext context) {
    final DouaaController controller = Get.put(DouaaController());

    return Scaffold(
      backgroundColor: DT.bg(context),
      appBar: AppBar(
        title: Text('Douaa'.trx, style: DT.titleLg(context)),
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
          GetBuilder<DouaaController>(
            builder: (ctrl) => IconButton(
              icon: const Icon(Icons.refresh, color: DT.blanc),
              onPressed: () => controller.refreshDuas(),
              tooltip: 'Actualiser'.trx,
            ),
          ),
        ],
      ),
      body: GetBuilder<DouaaController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: DT.accent(context),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Chargement...', style: DT.sub(context)),
                ],
              ),
            );
          }

          if (controller.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage,
                      textAlign: TextAlign.center,
                      style: DT.sub(context),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.refreshDuas(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DT.accent(context),
                        foregroundColor: DT.blanc,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Supplications'.trx,
                    style: DT.titleLg(context).copyWith(fontSize: 20),
                  ),
                ),

                // Two cards grid
                GridView.count(
                  crossAxisCount: 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _DouaCategoryCard(
                      title: 'Douaa du Coran'.trx,
                      subtitle: '${controller.quranDuas.length} ${'supplications'.trx}',
                      icon: Icons.menu_book_rounded,
                      count: controller.quranDuas.length,
                      onTap: () => Get.to(() => const DuaListView(
                            category: DuaCategory.quran,
                          )),
                    ),
                    _DouaCategoryCard(
                      title: 'Douaa du Prophète'.trx,
                      subtitle: '${controller.prophetDuas.length} ${'supplications'.trx}',
                      icon: Icons.auto_stories_rounded,
                      count: controller.prophetDuas.length,
                      onTap: () => Get.to(() => const DuaListView(
                            category: DuaCategory.prophet,
                          )),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info card
                Glass(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: DT.accent(context),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'À propos'.trx,
                              style: DT.titleMd(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Les douas sont des invocations tirées du Coran et de la Sunnah'.trx,
                              style: DT.sub(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Category Card Widget
// ═══════════════════════════════════════════════════════════════════════
class _DouaCategoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _DouaCategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  State<_DouaCategoryCard> createState() => _DouaCategoryCardState();
}

class _DouaCategoryCardState extends State<_DouaCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Glass(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: DT.accentGrad(context)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    color: DT.blanc,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: DT.titleLg(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: DT.sub(context),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: DT.accent(context).withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
