import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../routes/app_routes.dart';

class MenuCardsWidget extends StatelessWidget {
  const MenuCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (langController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section label ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [DT.orDark, DT.or],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Access'.trx,
                    style: DT.label(context),
                  ),
                ],
              ),
            ),

            // ── Grille ───────────────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.8,
              children: [
                _MenuCard(
                  title: 'Qibla'.trx,
                  subtitle: 'Direction'.trx,
                  icon: Icons.explore_rounded,
                  route: Routes.qibla,
                  gradient: DT.accentGrad(context),
                ),
                _MenuCard(
                  title: 'Tasbih'.trx,
                  subtitle: 'Dhikr'.trx,
                  icon: Icons.favorite_rounded,
                  route: Routes.tasbih,
                  gradient: DT.accentGrad(context),
                ),
                _MenuCard(
                  title: 'Quran'.trx,
                  subtitle: 'Listen'.trx,
                  icon: Icons.menu_book_rounded,
                  route: Routes.quran,
                  gradient: DT.accentGrad(context),
                ),
                _MenuCard(
                  title: 'Settings'.trx,
                  subtitle: 'Prayer'.trx,
                  icon: Icons.tune_rounded,
                  route: Routes.settings,
                  gradient: DT.accentGrad(context),
                ),
                _MenuCard(
                  title: 'Douaa'.trx,
                  subtitle: 'Supplications'.trx,
                  icon: Icons.self_improvement_rounded,
                  route: Routes.douaa,
                  gradient: DT.accentGrad(context),
                ),
                _MenuCard(
                  title: 'Wird'.trx,
                  subtitle: 'Daily'.trx,
                  icon: Icons.auto_stories_rounded,
                  route: Routes.wirdDaily,
                  gradient: DT.accentGrad(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
class _MenuCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final List<Color> gradient;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.gradient,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        Future.delayed(const Duration(milliseconds: 120), () {
          Get.toNamed(widget.route);
        });
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Glass(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Icône dans un carré arrondi avec fond teinté
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.gradient.first.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.gradient.first, size: 16),
                ),
                const SizedBox(width: 8),
                // Textes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: DT.titleMd(context).copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.subtitle,
                        style: DT.sub(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Flèche subtile
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: widget.gradient.first.withValues(alpha: 0.50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
