import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../../../core/widgets/language_switcher.dart';
import '../controllers/reciter_controller.dart';
import '../models/reciter_model.dart';

class ReciterListPage extends StatelessWidget {
  const ReciterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReciterController controller = Get.find<ReciterController>();
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
            Icon(Icons.person_outline, color: DT.or, size: 18),
            const SizedBox(width: 7),
            Text(
              'Select Reciter'.trx,
              style: DT.titleLg(context),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          const LanguageSwitcher(),
          IconButton(
            icon: Icon(Icons.refresh, color: DT.or),
            onPressed: () => controller.refreshReciters(),
            tooltip: 'Refresh'.trx,
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep, color: DT.or),
            onPressed: () => controller.resetRecitersCache(),
            tooltip: 'Reset Cache'.trx,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: GetBuilder<ReciterController>(
        builder: (controller) {
          if (controller.reciters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: DT.or,
                      strokeWidth: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading reciters...',
                    style: DT.sub(context),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.reciters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final reciter = controller.reciters[index];
              final isSelected = controller.selectedReciterId == reciter.id;

              return _ReciterRow(
                reciter: reciter,
                isSelected: isSelected,
                onSelect: () {
                  controller.selectReciter(reciter.id);
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Selected ${reciter.nameFr}',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ReciterRow extends StatelessWidget {
  final Reciter reciter;
  final bool isSelected;
  final VoidCallback onSelect;

  const _ReciterRow({required this.reciter, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Glass(
        forceBorder: isSelected ? DT.or.withValues(alpha: 0.5) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reciter.nameFr,
                    style: DT.titleMd(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reciter.nameAr,
                    style: DT.titleMd(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DT.subC(context),
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.chevron_right,
              color: isSelected ? DT.accent(context) : DT.subC(context),
              size: isSelected ? 20 : 18,
            ),
          ],
        ),
      ),
    );
  }
}
