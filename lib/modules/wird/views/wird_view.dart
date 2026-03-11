import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../controllers/wird_controller.dart';

/// Daily Wird Screen - POC Version
/// Simple UI to test the Wird system
class WirdView extends StatelessWidget {
  const WirdView({super.key});

  @override
  Widget build(BuildContext context) {
    final WirdController controller = Get.put(WirdController());

    return Scaffold(
      backgroundColor: DT.bg(context),
      appBar: AppBar(
        title: Text('Wird Quotidien', style: DT.titleLg(context)),
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
          IconButton(
            icon: const Icon(Icons.settings, color: DT.blanc),
            onPressed: () => Get.toNamed('/wird-settings'),
            tooltip: 'Paramètres',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: DT.blanc),
            onPressed: () => controller.refresh(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage, style: DT.sub(context)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.loadWird(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final wird = controller.currentWird;
        if (wird == null) {
          return const Center(
            child: Text('Aucun Wird disponible'),
          );
        }

        return Column(
          children: [
            // Header with progress
            _buildHeader(context, controller),
            
            // Verses list
            Expanded(
              child: _buildVersesList(context, controller, wird),
            ),
            
            // Action button
            _buildActionButton(context, controller, wird),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, WirdController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: DT.accentGrad(context)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Title
          Text(
            controller.getWelcomeMessage(),
            style: DT.titleLg(context).copyWith(color: DT.blanc, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          _buildProgressBar(context, controller),
          const SizedBox(height: 12),
          
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                icon: Icons.book_online,
                label: 'Verset',
                value: '${controller.currentWird?.verseCount ?? 0}',
              ),
              _buildStatItem(
                context,
                icon: Icons.local_fire_department,
                label: 'Série',
                value: '${controller.streak}',
              ),
              _buildStatItem(
                context,
                icon: Icons.trending_up,
                label: 'Progress',
                value: '${controller.progressPercent.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, WirdController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: controller.progressPercent / 100,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 8,
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: DT.blanc, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: DT.titleMd(context).copyWith(color: DT.blanc, fontSize: 16),
        ),
        Text(
          label,
          style: DT.sub(context).copyWith(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildVersesList(
    BuildContext context,
    WirdController controller,
    dynamic wird,
  ) {
    if (wird.isQuranComplete == true) {
      return _buildKhatmMessage(context);
    }

    if (wird.verses.isEmpty) {
      return const Center(
        child: Text('Aucun verset à afficher'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wird.verses.length,
      itemBuilder: (context, index) {
        final verse = wird.verses[index];
        return _buildVerseCard(context, controller, verse, index + 1);
      },
    );
  }

  Widget _buildKhatmMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: DT.accent(context),
            ),
            const SizedBox(height: 24),
            Text(
              '🎉 Félicitations !',
              style: DT.titleLg(context).copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous avez complété le Coran',
              style: DT.sub(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(BuildContext context, WirdController controller, dynamic verse, int index) {
    final langController = Get.find<LanguageController>();
    final isArabic = langController.currentLang == 'ar';

    return Glass(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Verse number badge
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: DT.accentGrad(context)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: DT.blanc,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sourate ${verse.surahNumber}, Verset ${verse.ayahNumber}',
                  style: DT.sub(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Arabic text
            Text(
              verse.textAr,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                height: 2,
                color: DT.or,
              ),
            ),
            const SizedBox(height: 16),
            
            // Translation
            Text(
              controller.getVerseText(verse),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: DT.sub(context).copyWith(fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WirdController controller,
    dynamic wird,
  ) {
    final isCompleted = controller.isTodayCompleted();
    final isKhatm = wird.isQuranComplete == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DT.bg(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (isCompleted && !isKhatm) ? null : () => controller.completeWird(),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.grey : DT.accent(context),
          foregroundColor: DT.blanc,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isKhatm ? Icons.emoji_events : Icons.check_circle_outline,
              color: DT.blanc,
            ),
            const SizedBox(width: 8),
            Text(
              controller.getCompleteButtonText(),
              style: DT.titleMd(context).copyWith(color: DT.blanc),
            ),
          ],
        ),
      ),
    );
  }
}
