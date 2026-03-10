import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../core/widgets/language_switcher.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    final dark = DT.dark(context);

    return Scaffold(
      backgroundColor: DT.bg(context),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: DT.bg(context),
            border: Border(
              bottom: BorderSide(
                color: DT.or.withValues(alpha: dark ? 0.30 : 0.20),
                width: 0.8,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings_outlined, color: DT.or, size: 18),
            const SizedBox(width: 7),
            Text(
              'Settings'.trx,
              style: DT.titleLg(context),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          const LanguageSwitcher(),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 4),
              _buildSection(
                title: 'Notifications'.trx,
                icon: Icons.notifications_outlined,
                context: context,
                children: [
                  GetBuilder<SettingsController>(
                    builder: (controller) => _buildSwitchTile(
                      title: 'Prayer Notifications'.trx,
                      subtitle: 'Get notified before each prayer'.trx,
                      icon: Icons.notifications_active,
                      value: controller.prayerNotifications.value,
                      onChanged: controller.togglePrayerNotifications,
                      context: context,
                    ),
                  ),
                  GetBuilder<SettingsController>(
                    builder: (controller) => _buildSwitchTile(
                      title: 'Adhan Sound'.trx,
                      subtitle: 'Play adhan sound at prayer time'.trx,
                      icon: Icons.volume_up,
                      value: controller.adhanSound.value,
                      onChanged: controller.toggleAdhanSound,
                      context: context,
                    ),
                  ),
                  GetBuilder<SettingsController>(
                    builder: (controller) => _buildSwitchTile(
                      title: 'Fajr Reminder'.trx,
                      subtitle: 'Special reminder for Fajr prayer'.trx,
                      icon: Icons.alarm,
                      value: controller.fajrReminder.value,
                      onChanged: controller.toggleFajrReminder,
                      context: context,
                    ),
                  ),
                ],
              ),
              _buildSection(
                title: 'Prayer Settings'.trx,
                icon: Icons.schedule,
                context: context,
                children: [
                  GetBuilder<SettingsController>(
                    builder: (controller) => _buildDropdownTile(
                      title: 'Calculation Method'.trx,
                      subtitle: controller.calcMethod.value,
                      icon: Icons.calculate,
                      items: [
                        const MapEntry('Muslim World League', 'Muslim World League'),
                        const MapEntry('Egyptian', 'Egyptian'),
                        const MapEntry('Karachi', 'Karachi'),
                        const MapEntry('Umm al-Qura', 'Umm al-Qura'),
                        const MapEntry('Dubai', 'Dubai'),
                      ].map((e) => MapEntry(e.key, e.value.trx)).toList(),
                      value: controller.calcMethod.value,
                      onChanged: (String? value) =>
                          controller.setCalculationMethod(value!),
                      context: context,
                    ),
                  ),
                  GetBuilder<SettingsController>(
                    builder: (controller) => _buildDropdownTile(
                      title: 'Asr Method'.trx,
                      subtitle: controller.asrMethod.value,
                      icon: Icons.access_time,
                      items: [
                        const MapEntry('Standard (Shafi)', 'Standard (Shafi)'),
                        const MapEntry('Hanafi', 'Hanafi'),
                      ].map((e) => MapEntry(e.key, e.value.trx)).toList(),
                      value: controller.asrMethod.value,
                      onChanged: (String? value) =>
                          controller.setAsrMethod(value!),
                      context: context,
                    ),
                  ),
                  GetBuilder<SettingsController>(
                    builder: (controller) => _buildSwitchTile(
                      title: 'Hijri Adjustment'.trx,
                      subtitle: 'Adjust Hijri date display'.trx,
                      icon: Icons.calendar_today,
                      value: controller.hijriAdjustment.value,
                      onChanged: controller.toggleHijriAdjustment,
                      context: context,
                    ),
                  ),
                ],
              ),
              _buildSection(
                title: 'Appearance'.trx,
                icon: Icons.palette_outlined,
                context: context,
                children: [
                  GetBuilder<SettingsController>(
                    builder: (controller) => _buildSwitchTile(
                      title: 'Dark Mode'.trx,
                      subtitle: 'Use dark theme'.trx,
                      icon: Icons.dark_mode,
                      value: controller.darkMode.value,
                      onChanged: controller.toggleDarkMode,
                      context: context,
                    ),
                  ),
                ],
              ),
              _buildSection(
                title: 'About'.trx,
                icon: Icons.info_outline,
                context: context,
                children: [
                  _buildListTile(
                    title: 'App Version'.trx,
                    subtitle: '1.0.0',
                    icon: Icons.info,
                    onTap: () {},
                    context: context,
                  ),
                  _buildListTile(
                    title: 'Privacy Policy'.trx,
                    subtitle: 'Read our privacy policy'.trx,
                    icon: Icons.privacy_tip,
                    onTap: () => Get.toNamed('/privacy-policy'),
                    context: context,
                  ),
                  _buildListTile(
                    title: 'Terms of Service'.trx,
                    subtitle: 'View terms and conditions'.trx,
                    icon: Icons.description,
                    onTap: () => Get.toNamed('/terms-of-service'),
                    context: context,
                  ),
                  _buildListTile(
                    title: 'Rate App'.trx,
                    subtitle: 'Share your experience'.trx,
                    icon: Icons.star,
                    onTap: () {},
                    context: context,
                  ),
                  _buildListTile(
                    title: 'Reset to Defaults'.trx,
                    subtitle: 'Restore original settings'.trx,
                    icon: Icons.restore,
                    onTap: () => _showResetDialog(context, controller),
                    context: context,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(
    BuildContext context,
    SettingsController controller,
  ) async {
    final confirmed = await controller.showConfirmationDialog(
      title: 'Reset Settings'.trx,
      message:
          'Are you sure you want to reset all settings to their default values?'
              .tr,
    );

    if (confirmed) {
      await controller.resetToDefaults();
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: DT.accent(context)),
              const SizedBox(width: 8),
              Text(
                title,
                style: DT.label(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Glass(
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DT.accent(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: DT.accent(context), size: 20),
      ),
      title: Text(
        title,
        style: DT.titleMd(context),
      ),
      subtitle: Text(
        subtitle,
        style: DT.sub(context),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: DT.accent(context),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<MapEntry<String, String>> items,
    required String value,
    required ValueChanged<String?> onChanged,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DT.accent(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: DT.accent(context), size: 20),
      ),
      title: Text(
        title,
        style: DT.titleMd(context),
      ),
      subtitle: Text(
        subtitle,
        style: DT.sub(context),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: DT.subC(context)),
        items: items.map((MapEntry<String, String> item) {
          return DropdownMenuItem<String>(
            value: item.key,
            child: Text(item.value, style: DT.sub(context)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DT.accent(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: DT.accent(context), size: 20),
      ),
      title: Text(
        title,
        style: DT.titleMd(context),
      ),
      subtitle: Text(
        subtitle,
        style: DT.sub(context),
      ),
      trailing: Icon(Icons.chevron_right, color: DT.subC(context)),
      onTap: onTap,
    );
  }
}
