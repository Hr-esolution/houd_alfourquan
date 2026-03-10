import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../controllers/adhan_controller.dart';

class AdhanSettingsPage extends StatelessWidget {
  const AdhanSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdhanController controller = Get.find<AdhanController>();
    final dark = DT.dark(context);

    return Scaffold(
      backgroundColor: DT.bg(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: DT.bg(context),
            border: Border(
              bottom: BorderSide(color: DT.or.withValues(alpha: dark ? 0.30 : 0.20), width: 0.8),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up, color: DT.or, size: 18),
            const SizedBox(width: 7),
            Text(
              'Paramètres Adhan',
              style: DT.titleLg(context),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 80),
          // Section: Adhan locaux disponibles
          _buildSectionTitle(context, 'Adhan disponibles'),
          const SizedBox(height: 8),
          Glass(child: _buildLocalAdhanList(controller)),

          const SizedBox(height: 24),

          // Section: Paramètres par prière
          _buildSectionTitle(context, 'Paramètres par prière'),
          const SizedBox(height: 8),
          Glass(child: _buildPrayerSettingsList(controller)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: DT.label(context),
    );
  }

  Widget _buildLocalAdhanList(AdhanController controller) {
    return Column(
      children: AdhanController.localAdhans.map((adhan) {
        final id = adhan['id']!;
        return _DownloadableAdhanTile(
          adhan: adhan,
          onPreview: () => controller.previewAdhan(id, 'local'),
          isPlaying: controller.isPlayingPreview && controller.previewAdhanId == id,
        );
      }).toList(),
    );
  }

  Widget _buildPrayerSettingsList(AdhanController controller) {
    return Column(
      children: ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'].map((prayerName) {
        return GetBuilder<AdhanController>(
          id: 'adhan_$prayerName',
          builder: (controller) {
            final settings = controller.prayerSettings[prayerName];
            if (settings == null) return const SizedBox.shrink();

            return _PrayerAdhanTile(settings: settings, controller: controller);
          },
        );
      }).toList(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Adhan Tile
// ═════════════════════════════════════════════════════════════════════════════
class _DownloadableAdhanTile extends StatelessWidget {
  final Map<String, String> adhan;
  final VoidCallback onPreview;
  final bool isPlaying;

  const _DownloadableAdhanTile({
    required this.adhan,
    required this.onPreview,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final name = adhan['name']!;
    final nameAr = adhan['name_ar']!;

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [DT.orDark, DT.or],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPlaying ? Icons.volume_up : Icons.music_note,
              color: DT.blanc,
              size: 20,
            ),
          ),
          title: Text(
            name,
            style: DT.titleMd(context),
          ),
          subtitle: Text(
            nameAr,
            style: DT.sub(context),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionBtn(
                icon: isPlaying ? Icons.stop : Icons.play_arrow,
                onTap: onPreview,
                size: 30,
                colors: [DT.orDark, DT.or],
              ),
            ],
          ),
        ),
        Divider(height: 1, color: DT.divider(context)),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Prayer Adhan Tile
// ═════════════════════════════════════════════════════════════════════════════
class _PrayerAdhanTile extends StatelessWidget {
  final PrayerAdhanSettings settings;
  final AdhanController controller;

  const _PrayerAdhanTile({required this.settings, required this.controller});

  String get _prayerNameFr {
    switch (settings.prayerName) {
      case 'fajr': return 'Fajr (Aube)';
      case 'dhuhr': return 'Dhuhr (Zuhr)';
      case 'asr': return 'Asr';
      case 'maghrib': return 'Maghrib';
      case 'isha': return 'Isha';
      default: return settings.prayerName.capitalizeFirst ?? '';
    }
  }

  String get _prayerNameAr {
    switch (settings.prayerName) {
      case 'fajr': return 'الفجر';
      case 'dhuhr': return 'الظهر';
      case 'asr': return 'العصر';
      case 'maghrib': return 'المغرب';
      case 'isha': return 'العشاء';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: settings.isEnabled ? DT.accentGrad(context) : [Colors.grey.shade400, Colors.grey.shade300],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: DT.blanc,
              size: 20,
            ),
          ),
          title: Text(
            _prayerNameFr,
            style: DT.titleMd(context),
          ),
          subtitle: Text(
            _prayerNameAr,
            style: DT.sub(context),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (settings.isEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: DT.borderColor(context)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: settings.adhanId,
                    underline: const SizedBox(),
                    items: AdhanController.localAdhans
                        .map((adhan) => DropdownMenuItem(
                              value: adhan['id'],
                              child: Text(
                                adhan['name'] ?? '',
                                style: DT.sub(context).copyWith(fontSize: 12),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setAdhanForPrayer(settings.prayerName, value, 'local');
                      }
                    },
                  ),
                ),
              const SizedBox(width: 8),
              Switch(
                value: settings.isEnabled,
                onChanged: (_) => controller.togglePrayerAdhan(settings.prayerName),
                activeThumbColor: DT.accent(context),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: DT.divider(context)),
      ],
    );
  }
}
