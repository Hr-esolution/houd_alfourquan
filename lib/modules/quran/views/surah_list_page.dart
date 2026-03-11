import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../routes/app_routes.dart';
import '../controllers/reciter_controller.dart';
import '../controllers/player_controller.dart';
import '../models/surah_model.dart';
import 'surah_download_page.dart';
import 'reciter_list_page.dart';

// ══════════════════════════════════════════════════════════════
//  PALETTE — STRICT
//  Dark  : noir #0A0A0A · or #C9A84C · blanc #FFFFFF
//  Light : noir #0A0A0A · blanc #FFFFFF · vert #1B5E20 · or #C9A84C
// ══════════════════════════════════════════════════════════════
class _C {
  // Shared
  static const noir = Color(0xFF0A0A0A);
  static const blanc = Color(0xFFFFFFFF);
  static const or = Color(0xFFC9A84C);
  static const orLight = Color(0xFFE8C96A);
  static const orDark = Color(0xFF8A6A1E);

  // Light only
  static const vert = Color(0xFF1B5E20);
  static const vertLight = Color(0xFF2E7D32);

  // Dark surfaces
  static const darkCard = Color(0xFF181818);

  // Helpers
  static bool dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color bg(BuildContext c) => dark(c) ? noir : blanc;
  static Color glass(BuildContext c) =>
      dark(c) ? blanc.withValues(alpha: 0.05) : noir.withValues(alpha: 0.03);
  static Color borderColor(BuildContext c) =>
      dark(c) ? or.withValues(alpha: 0.25) : noir.withValues(alpha: 0.08);
  static Color accent(BuildContext c) => dark(c) ? or : vert;
  static Color txt(BuildContext c) => dark(c) ? blanc : noir;
  static Color sub(BuildContext c) =>
      dark(c) ? blanc.withValues(alpha: 0.45) : noir.withValues(alpha: 0.45);
  static Color divider(BuildContext c) =>
      dark(c) ? blanc.withValues(alpha: 0.06) : noir.withValues(alpha: 0.07);
}

// ──────────────────────────────────────────────────────────────
//  Glass container
// ──────────────────────────────────────────────────────────────
class _Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding, margin;
  final Color? forceBorder;

  const _Glass({
    required this.child,
    this.padding,
    this.margin,
    this.forceBorder,
  });

  @override
  Widget build(BuildContext c) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: _C.glass(c),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: forceBorder ?? _C.borderColor(c), width: .8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _C.dark(c) ? .35 : .06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}

// ──────────────────────────────────────────────────────────────
//  Gradient badge helper
// ──────────────────────────────────────────────────────────────
List<Color> _accentGrad(BuildContext c) =>
    _C.dark(c) ? [_C.orDark, _C.or] : [_C.vert, _C.vertLight];

// ══════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════
class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final dark = _C.dark(context);

    return Scaffold(
      backgroundColor: _C.bg(context),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: _C.bg(context),
            border: Border(
              bottom: BorderSide(
                color: _C.or.withValues(alpha: dark ? .30 : .20),
                width: .8,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_outlined, color: _C.or, size: 17),
            const SizedBox(width: 7),
            Text(
              'Holy Quran'.trx,
              style: TextStyle(
                color: dark ? _C.or : _C.noir,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: .6,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          const LanguageSwitcher(),
          _NavBtn(
            Icons.person_outline,
            'Select Reciter'.trx,
            () => Get.to(() => const ReciterListPage()),
          ),
          _NavBtn(
            Icons.download_outlined,
            'Download Surahs'.trx,
            () => Get.to(() => const SurahDownloadPage()),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: GetBuilder<ReciterController>(
        builder: (rc) {
          if (rc.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: _C.or,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading Quran data...',
                    style: TextStyle(color: _C.sub(context), fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
              SliverToBoxAdapter(child: _reciterCard(context)),
              SliverToBoxAdapter(child: _playerBar(context, playerController)),
              SliverToBoxAdapter(child: _listHeader(context)),
              _surahSliver(context, playerController),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  // ── Reciter card ────────────────────────────────────────────
  Widget _reciterCard(BuildContext c) {
    final rc = Get.find<ReciterController>();
    final cnt = rc.downloadedSurahs[rc.selectedReciterId]?.length ?? 0;
    final dark = _C.dark(c);

    return GestureDetector(
      onTap: () => Get.to(() => const ReciterListPage()),
      child: _Glass(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.all(12),
        forceBorder: _C.or.withValues(alpha: dark ? .30 : .18),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _accentGrad(c)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.headphones, color: _C.blanc, size: 19),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rc.selectedReciter?.nameFr ?? 'Select a reciter',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.txt(c),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$cnt surahs downloaded',
                    style: TextStyle(fontSize: 10, color: _C.sub(c)),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: _C.or.withValues(alpha: .55),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── Player bar ──────────────────────────────────────────────
  Widget _playerBar(BuildContext c, PlayerController pc) {
    if (!pc.isPlaying || pc.currentSurah == 0) return const SizedBox.shrink();
    final rc = Get.find<ReciterController>();
    final surah = rc.surahs.firstWhere(
      (s) => s.number == pc.currentSurah,
      orElse: () => rc.surahs.first,
    );

    return _Glass(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      forceBorder: _C.or.withValues(alpha: .55),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.orDark, _C.or],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.graphic_eq, color: _C.blanc, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.translatedName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _C.txt(c),
                  ),
                ),
                Text(
                  pc.currentReciterName.isNotEmpty 
                      ? pc.currentReciterName 
                      : 'Now playing',
                  style: TextStyle(
                    fontSize: 9,
                    color: _C.or.withValues(alpha: .75),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _MiniBtn(Icons.pause_rounded, _C.or, () => pc.playPause()),
          const SizedBox(width: 6),
          _MiniBtn(Icons.stop_rounded, _C.sub(c), () => pc.stop()),
        ],
      ),
    );
  }

  // ── List header ─────────────────────────────────────────────
  Widget _listHeader(BuildContext c) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
    child: Row(
      children: [
        Text(
          'All Surahs'.trx,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _C.or,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: _C.or.withValues(alpha: .35)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '114',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _C.or,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Surah sliver ────────────────────────────────────────────
  Widget _surahSliver(BuildContext c, PlayerController pc) {
    final rc = Get.find<ReciterController>();
    if (rc.surahs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(color: _C.or, strokeWidth: 1.5),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _SurahItem(surah: rc.surahs[i], pc: pc),
          childCount: rc.surahs.length,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Surah item
// ══════════════════════════════════════════════════════════════
class _SurahItem extends StatelessWidget {
  final Surah surah;
  final PlayerController pc;
  const _SurahItem({required this.surah, required this.pc});

  @override
  Widget build(BuildContext c) {
    return GetBuilder<ReciterController>(
      id: 'download_${surah.number}',
      builder: (rc) {
        final downloaded = rc.isDownloaded(surah.number);

        return _Glass(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: downloaded
                      ? LinearGradient(
                          colors: _accentGrad(c),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: downloaded ? null : _C.divider(c),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: downloaded
                        ? _C.or.withValues(alpha: .45)
                        : _C.borderColor(c),
                    width: .7,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: TextStyle(
                      color: downloaded ? _C.blanc : _C.sub(c),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.translatedName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.txt(c),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${surah.ayahCount} verses · ${surah.translatedRevelationType}',
                      style: TextStyle(fontSize: 10, color: _C.sub(c)),
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Download
                  GetBuilder<ReciterController>(
                    id: 'download_${surah.number}',
                    builder: (ctrl) {
                      final loading = ctrl.isDownloading[surah.number] ?? false;
                      final done = ctrl.isDownloaded(surah.number);
                      if (loading) {
                        return SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: _C.or,
                          ),
                        );
                      }
                      if (done) {
                        return Icon(
                          Icons.download_done_rounded,
                          color: _C.accent(c),
                          size: 18,
                        );
                      }
                      return _ActionBtn(
                        icon: Icons.cloud_download_outlined,
                        colors: _C.dark(c)
                            ? [_C.darkCard, _C.darkCard]
                            : [_C.blanc, _C.blanc],
                        border: _C.or.withValues(alpha: .4),
                        iconColor: _C.or,
                        tooltip: 'Download',
                        onTap: () => ctrl.downloadSurah(surah.number),
                      );
                    },
                  ),
                  const SizedBox(width: 6),

                  // Read
                  _ActionBtn(
                    icon: Icons.menu_book_rounded,
                    colors: _accentGrad(c),
                    tooltip: 'Lire le texte',
                    onTap: () => Get.toNamed(
                      Routes.surahReading,
                      arguments: {
                        'surahNumber': surah.number,
                        'surahName': surah.translatedName,
                      },
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Play
                  GetBuilder<PlayerController>(
                    builder: (p) {
                      final playing =
                          p.isPlaying && p.currentSurah == surah.number;
                      return _ActionBtn(
                        icon: playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        colors: playing
                            ? [_C.orDark, _C.orLight]
                            : _accentGrad(c),
                        tooltip: playing ? 'Pause' : 'Play',
                        onTap: () => playing
                            ? p.playPause()
                            : p.playOrStream(surah.number),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Micro widgets
// ══════════════════════════════════════════════════════════════

/// AppBar nav button
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _NavBtn(this.icon, this.tooltip, this.onTap);

  @override
  Widget build(BuildContext c) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: _C.dark(c) ? _C.or : _C.noir, size: 20),
      ),
    ),
  );
}

/// Mini icon button (player bar)
class _MiniBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MiniBtn(this.icon, this.color, this.onTap);

  @override
  Widget build(_) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, color: color, size: 22),
  );
}

/// Gradient action button (30×30)
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final String tooltip;
  final VoidCallback onTap;
  final Color? border;
  final Color? iconColor;
  const _ActionBtn({
    required this.icon,
    required this.colors,
    required this.tooltip,
    required this.onTap,
    this.border,
    this.iconColor,
  });

  @override
  Widget build(_) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: border != null ? Border.all(color: border!, width: .8) : null,
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: .30),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? _C.blanc, size: 16),
      ),
    ),
  );
}
