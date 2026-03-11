import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../core/widgets/language_switcher.dart';
import '../controllers/prayer_controller.dart';

/// Prayer View - Updated with DT design tokens and translations
class PrayerView extends StatelessWidget {
  const PrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrayerController>(
      builder: (controller) {
        if (controller.isLoading) {
          return _LoadingState(context: context);
        }

        if (controller.hasError) {
          return _ErrorState(
            context: context,
            errorMessage: controller.errorMessage,
            onRetry: () => controller.loadPrayerTimes(),
          );
        }

        return _PrayerContent(context: context, controller: controller);
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  final BuildContext context;

  const _LoadingState({required this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.bg(this.context),
      appBar: AppBar(
        title: Text('Prayer Times'.trx, style: DT.titleLg(this.context)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: DT.accentGrad(this.context),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: const [LanguageSwitcher()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DT.accent(this.context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(color: DT.accent(this.context)),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading'.trx,
              style: DT.sub(this.context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final BuildContext context;
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.context,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final prayerController = Get.find<PrayerController>();
    
    return Scaffold(
      backgroundColor: DT.bg(this.context),
      appBar: AppBar(
        title: Text('Prayer Times'.trx, style: DT.titleLg(this.context)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: DT.accentGrad(this.context),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: const [LanguageSwitcher()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off,
                  size: 48,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Position non disponible',
                style: DT.titleLg(this.context),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: DT.sub(this.context),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: prayerController.selectCityManually,
                    icon: const Icon(Icons.location_city),
                    label: const Text('Choisir une ville'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DT.accent(this.context),
                      foregroundColor: DT.blanc,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text('Réessayer'.trx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DT.accent(this.context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerContent extends StatelessWidget {
  final BuildContext context;
  final PrayerController controller;

  const _PrayerContent({required this.context, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.bg(this.context),
      appBar: AppBar(
        title: Text('Prayer Times'.trx, style: DT.titleLg(this.context)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: DT.accentGrad(this.context),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          const LanguageSwitcher(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshLocation,
            tooltip: 'Actualiser la position',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              if (controller.prayerTimes != null) ..._buildPrayerTiles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Glass(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DT.accent(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.location_on, color: DT.accent(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.cityName,
                  style: DT.titleMd(context),
                ),
                Text(
                  DateTime.now().toString().substring(0, 10),
                  style: DT.sub(context),
                ),
              ],
            ),
          ),
          if (controller.isDefaultLocation) ...[
            IconButton(
              icon: const Icon(Icons.edit_location, size: 20),
              onPressed: controller.selectCityManually,
              tooltip: 'Changer de ville',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildPrayerTiles() {
    if (controller.prayerTimes == null) return [];
    final prayerTimes = controller.prayerTimes!;
    return [
      _buildPrayerTile('fajr', prayerTimes.fajr.toString().substring(0, 5)),
      _buildPrayerTile('dhuhr', prayerTimes.dhuhr.toString().substring(0, 5)),
      _buildPrayerTile('asr', prayerTimes.asr.toString().substring(0, 5)),
      _buildPrayerTile('maghrib', prayerTimes.maghrib.toString().substring(0, 5)),
      _buildPrayerTile('isha', prayerTimes.isha.toString().substring(0, 5)),
    ];
  }

  Widget _buildPrayerTile(String name, String time) {
    return GetBuilder<LanguageController>(
      builder: (langController) {
        return Glass(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DT.accent(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getPrayerIcon(name),
                  color: DT.accent(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getPrayerNameTranslated(name),
                  style: DT.titleMd(context),
                ),
              ),
              Text(
                time,
                style: DT.titleMd(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: DT.accent(context),
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

  IconData _getPrayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fajr': return Icons.nights_stay;
      case 'dhuhr': return Icons.wb_sunny;
      case 'asr': return Icons.wb_twilight;
      case 'maghrib': return Icons.nightlight;
      case 'isha': return Icons.star;
      default: return Icons.access_time;
    }
  }
}
