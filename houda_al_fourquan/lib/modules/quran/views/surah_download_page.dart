import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../controllers/reciter_controller.dart';
import '../models/surah_model.dart';

class SurahDownloadPage extends StatelessWidget {
  const SurahDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.download, color: DT.or, size: 18),
            const SizedBox(width: 7),
            const Text(
              'Download Surahs',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.6),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          GetBuilder<ReciterController>(
            id: 'bulk_download',
            builder: (controller) {
              if (controller.isBulkDownloading) {
                return IconButton(
                  icon: Icon(Icons.stop_circle, color: DT.or),
                  onPressed: () => controller.cancelBulkDownload(),
                  tooltip: 'Cancel',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 80),
          GetBuilder<ReciterController>(
            builder: (controller) {
              final reciter = controller.selectedReciter;
              final downloadedCount = controller.downloadedSurahs[controller.selectedReciterId]?.length ?? 0;

              return Glass(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reciter?.translatedName ?? 'Select a reciter',
                              style: DT.titleMd(context).copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            DHBadge(text: '$downloadedCount/114'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${controller.totalUsedSpaceMb.toStringAsFixed(1)} MB',
                              style: DT.titleMd(context).copyWith(color: DT.or),
                            ),
                            Text('used', style: DT.sub(context)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GetBuilder<ReciterController>(
                      id: 'bulk_download',
                      builder: (controller) {
                        if (controller.isBulkDownloading) {
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: controller.bulkProgressCurrent / controller.bulkProgressTotal,
                                backgroundColor: DT.divider(context),
                                valueColor: AlwaysStoppedAnimation(DT.or),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Downloading ${controller.bulkProgressCurrent}/114',
                                    style: DT.sub(context),
                                  ),
                                  TextButton(
                                    onPressed: () => controller.cancelBulkDownload(),
                                    child: Text('Cancel', style: DT.sub(context)),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          child: ActionBtn(
                            icon: Icons.download,
                            onTap: () => controller.downloadAllSequential(),
                            tooltip: 'Download All',
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: GetBuilder<ReciterController>(
              builder: (controller) {
                if (controller.surahs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.surahs.length,
                  itemBuilder: (context, index) {
                    final surah = controller.surahs[index];
                    return _SurahDownloadItem(surah: surah);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahDownloadItem extends StatelessWidget {
  final Surah surah;

  const _SurahDownloadItem({required this.surah});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReciterController>(
      id: 'download_${surah.number}',
      builder: (controller) {
        final isDownloaded = controller.isDownloaded(surah.number);
        final isDownloading = controller.isDownloading[surah.number] ?? false;
        final progress = controller.downloadProgress[surah.number] ?? 0.0;

        return Glass(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isDownloaded ? LinearGradient(colors: DT.accentGrad(context)) : null,
                    color: isDownloaded ? null : DT.divider(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: DT.blanc,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  surah.nameFr,
                  style: DT.titleMd(context),
                ),
                subtitle: Text(
                  surah.nameAr,
                  style: DT.sub(context),
                ),
                trailing: _buildActionWidget(
                  context,
                  controller,
                  surah.number,
                  isDownloaded,
                  isDownloading,
                  progress,
                ),
              ),
              if (isDownloading && progress > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: DT.divider(context),
                    valueColor: AlwaysStoppedAnimation(DT.or),
                    minHeight: 4,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionWidget(
    BuildContext context,
    ReciterController controller,
    int surahNumber,
    bool isDownloaded,
    bool isDownloading,
    double progress,
  ) {
    if (isDownloading) {
      return SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: progress > 0 ? progress : null,
          valueColor: AlwaysStoppedAnimation(DT.or),
        ),
      );
    }

    if (isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: DT.accent(context), size: 20),
          const SizedBox(width: 8),
          ActionBtn(
            icon: Icons.delete_outline,
            onTap: () => controller.deleteSurah(surahNumber),
            size: 30,
            colors: [Colors.red.shade400, Colors.red.shade300],
          ),
        ],
      );
    }

    return ActionBtn(
      icon: Icons.cloud_download,
      onTap: () => controller.downloadSurah(surahNumber),
      size: 30,
      colors: [DT.orDark, DT.or],
    );
  }
}
