import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../controllers/douaa_controller.dart';
import '../models/dua_model.dart';

class DuaListView extends StatelessWidget {
  final DuaCategory category;

  const DuaListView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final DouaaController controller = Get.find<DouaaController>();
    final duas = controller.getDuasByCategory(category);

    return Scaffold(
      backgroundColor: DT.bg(context),
      appBar: AppBar(
        title: Text(controller.getCategoryName(category).trx, style: DT.titleLg(context)),
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
      body: duas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune douaa disponible'.trx,
                    style: DT.titleMd(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cette catégorie sera bientôt disponible'.trx,
                    style: DT.sub(context),
                  ),
                ],
              ),
            )
          : GetBuilder<LanguageController>(
              builder: (langCtrl) {
                return ListView.builder(
                  key: ValueKey('dua-list-${langCtrl.currentLang}'),
                  padding: const EdgeInsets.all(16),
                  itemCount: duas.length,
                  itemBuilder: (context, index) {
                    final dua = duas[index];
                    return _DuaCard(
                      dua: dua,
                      index: index + 1,
                      langCode: langCtrl.currentLang,
                    );
                  },
                );
              },
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Dua Card Widget
// ═══════════════════════════════════════════════════════════════════════
class _DuaCard extends StatefulWidget {
  final DuaModel dua;
  final int index;
  final String langCode;

  const _DuaCard({
    required this.dua,
    required this.index,
    required this.langCode,
  });

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isArabicLang = widget.langCode == 'ar';
    final displayText = _getDisplayText();

    return Glass(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: DT.accentGrad(context)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: const TextStyle(
                        color: DT.blanc,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Douaa ${widget.index}',
                        style: DT.titleMd(context),
                      ),
                      if (widget.dua.reference.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.dua.reference,
                          style: DT.sub(context).copyWith(fontSize: 9),
                        ),
                      ],
                    ],
                  ),
                ),
                // Expand button
                IconButton(
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Main text (Arabic or translation based on language)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              displayText,
              textAlign: isArabicLang ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontFamily: isArabicLang ? 'Amiri' : null,
                fontSize: isArabicLang ? 22 : 14,
                height: isArabicLang ? 2 : 1.5,
                color: isArabicLang ? DT.or : DT.txt(context),
              ),
            ),
          ),

          // Repeat count
          if (widget.dua.repeat > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: DT.accent(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 14,
                      color: DT.accent(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRepeatText(),
                      style: DT.sub(context).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

          // Expanded content with reference and additional info
          if (_isExpanded && widget.dua.reference.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.book,
                        size: 16,
                        color: DT.accent(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Référence',
                        style: DT.titleMd(context).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.dua.reference,
                    style: DT.sub(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Get text to display based on current language
  String _getDisplayText() {
    switch (widget.langCode) {
      case 'ar':
        // Arabic language: show Arabic text
        return widget.dua.arabic;
      case 'en':
        // English language: show English translation
        return widget.dua.translationEn;
      case 'fr':
      default:
        // French language: show French translation
        return widget.dua.translationFr;
    }
  }

  String _getRepeatText() {
    switch (widget.langCode) {
      case 'ar':
        return 'تكرار ${widget.dua.repeat} مرات';
      case 'en':
        return 'Repeat ${widget.dua.repeat} times';
      case 'fr':
      default:
        return 'À répéter ${widget.dua.repeat} fois';
    }
  }
}
