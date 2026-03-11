import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../controllers/wird_controller.dart';

/// Settings screen for Daily Wird
/// Allows user to configure daily goal and reminder time
class WirdSettingsView extends StatelessWidget {
  const WirdSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final WirdController controller = Get.find<WirdController>();

    return Scaffold(
      backgroundColor: DT.bg(context),
      appBar: AppBar(
        title: Text('Paramètres', style: DT.titleLg(context)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal Section
            _buildSection(
              context,
              title: 'Objectif Quotidien',
              icon: Icons.flag,
              child: _buildDailyGoalSelector(context, controller),
            ),
            const SizedBox(height: 20),

            // Reminder Time Section
            _buildSection(
              context,
              title: 'Rappel Quotidien',
              icon: Icons.notifications_active,
              child: _buildReminderTimeSelector(context, controller),
            ),
            const SizedBox(height: 20),

            // Progress Section
            _buildSection(
              context,
              title: 'Progression',
              icon: Icons.insights,
              child: _buildProgressInfo(context, controller),
            ),
            const SizedBox(height: 20),

            // Actions Section
            _buildSection(
              context,
              title: 'Actions',
              icon: Icons.settings_suggest,
              child: _buildActions(context, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Glass(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DT.accent(context), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: DT.titleMd(context),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildDailyGoalSelector(
    BuildContext context,
    WirdController controller,
  ) {
    final goals = [10, 20, 30, 40, 50];
    final currentGoal = controller.progress.dailyGoal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre de versets à lire par jour',
          style: DT.sub(context),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: goals.map((goal) {
            final isSelected = goal == currentGoal;
            return ChoiceChip(
              label: Text('$goal'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.updateDailyGoal(goal);
                }
              },
              selectedColor: DT.accent(context),
              labelStyle: TextStyle(
                color: isSelected ? DT.blanc : DT.txt(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: DT.accent(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getGoalDescription(currentGoal, Get.find<LanguageController>().currentLang),
                style: DT.sub(context).copyWith(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderTimeSelector(
    BuildContext context,
    WirdController controller,
  ) {
    final currentReminder = controller.progress.reminderTime ?? '21:00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heure de rappel pour la lecture',
          style: DT.sub(context),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final time = await _selectTime(context, currentReminder);
                  if (time != null) {
                    controller.updateReminderTime(time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DT.glass(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DT.borderColor(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: DT.accent(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatTimeDisplay(currentReminder),
                        style: DT.titleMd(context),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.edit,
                        size: 18,
                        color: DT.subC(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 16, color: DT.accent(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Choisissez un moment calme pour votre lecture quotidienne',
                style: DT.sub(context).copyWith(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressInfo(
    BuildContext context,
    WirdController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: controller.progressPercent / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(DT.accent(context)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              label: 'Progress',
              value: '${controller.progressPercent.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
            ),
            _buildStatItem(
              context,
              label: 'Série',
              value: '${controller.streak}',
              icon: Icons.local_fire_department,
            ),
            _buildStatItem(
              context,
              label: 'Jours lus',
              value: '${controller.progress.completedDates.length}',
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: DT.accent(context), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: DT.titleMd(context).copyWith(
            color: DT.accent(context),
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: DT.sub(context).copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    WirdController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Restart button
        OutlinedButton.icon(
          onPressed: () => controller.restartReading(),
          icon: const Icon(Icons.refresh),
          label: const Text('Recommencer la lecture'),
          style: OutlinedButton.styleFrom(
            foregroundColor: DT.accent(context),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        // Reset button
        OutlinedButton.icon(
          onPressed: () => _confirmReset(context, controller),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text(
            'Réinitialiser la progression',
            style: TextStyle(color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<String?> _selectTime(
    BuildContext context,
    String currentTime,
  ) async {
    final timeParts = currentTime.split(':');
    final initialHour = int.parse(timeParts[0]);
    final initialMinute = int.parse(timeParts[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DT.accent(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }

    return null;
  }

  String _formatTimeDisplay(String time) {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _getGoalDescription(int goal, String lang) {
    final descriptions = {
      'fr': {
        10: '~5 minutes de lecture',
        20: '~10 minutes de lecture',
        30: '~15 minutes de lecture',
        40: '~20 minutes de lecture',
        50: '~25 minutes de lecture',
      },
      'en': {
        10: '~5 minutes of reading',
        20: '~10 minutes of reading',
        30: '~15 minutes of reading',
        40: '~20 minutes of reading',
        50: '~25 minutes of reading',
      },
      'ar': {
        10: '~5 دقائق من القراءة',
        20: '~10 دقائق من القراءة',
        30: '~15 دقيقة من القراءة',
        40: '~20 دقيقة من القراءة',
        50: '~25 دقيقة من القراءة',
      },
    };

    return descriptions[lang]?[goal] ?? '~10 minutes';
  }

  void _confirmReset(BuildContext context, WirdController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Réinitialiser ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser toute votre progression ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // Reset functionality to be implemented
              Get.snackbar(
                'Info',
                'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}
