import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = DT.dark(context);
    final langController = Get.find<LanguageController>();
    final textDirection =
        langController.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
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
              Icon(Icons.description_outlined, color: DT.or, size: 18),
              const SizedBox(width: 7),
              Text(
                'Terms of Service'.trx,
                style: DT.titleLg(context),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: DefaultTextStyle.merge(
            textAlign: TextAlign.start,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      number: '1',
                      title: 'acceptance'.trx,
                      content: 'termsAcceptance'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '2',
                      title: 'services'.trx,
                      content: 'servicesDescription'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '3',
                      title: 'userResponsibilities'.trx,
                      children: [
                        _buildListItem(context, '• accurateInfo'.trx),
                        _buildListItem(context, '• respectfulUse'.trx),
                        _buildListItem(context, '• noMisuse'.trx),
                        _buildListItem(context, '• privacyCompliance'.trx),
                      ],
                    ),
                    _buildSection(
                      context,
                      number: '4',
                      title: 'intellectualProperty'.trx,
                      content: 'ipRights'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '5',
                      title: 'prohibitedConduct'.trx,
                      children: [
                        _buildListItem(context, '• noIllegalActivities'.trx),
                        _buildListItem(context, '• noHarassment'.trx),
                        _buildListItem(context, '• noInterference'.trx),
                        _buildListItem(context, '• noCommercialUse'.trx),
                      ],
                    ),
                    _buildSection(
                      context,
                      number: '6',
                      title: 'disclaimer'.trx,
                      content: 'disclaimerContent'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '7',
                      title: 'limitationOfLiability'.trx,
                      content: 'liabilityLimitation'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '8',
                      title: 'modifications'.trx,
                      content: 'termsModifications'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '9',
                      title: 'termination'.trx,
                      content: 'accountTermination'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '10',
                      title: 'governingLaw'.trx,
                      content: 'governingLawContent'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '11',
                      title: 'contact'.trx,
                      content: 'contactInfo'.trx,
                    ),
                    const SizedBox(height: 24),
                    _buildFooter(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DT.or.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description, color: DT.or, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Terms of Service'.trx,
                      style: DT.titleLg(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Houda Al Fourquan',
                      style: DT.sub(context).copyWith(color: DT.subC(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: DT.accent(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.update, size: 14, color: DT.accent(context)),
                const SizedBox(width: 8),
                Text(
                  'Last updated: March 10, 2026'.trx,
                  style: DT.sub(context).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String number,
    required String title,
    String? content,
    List<Widget>? children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Glass(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DT.or.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    number,
                    style: DT.titleMd(context).copyWith(color: DT.or, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: DT.titleMd(context).copyWith(color: DT.or),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (content != null)
              Text(
                content,
                style: DT.titleMd(context).copyWith(height: 1.6, fontWeight: FontWeight.w400),
              ),
            if (children != null) ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: DT.titleMd(context).copyWith(height: 1.5, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: DT.or),
              const SizedBox(width: 8),
              Text('importantNotice'.trx, style: DT.titleMd(context)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DT.accent(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DT.accent(context).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'legalBindingNotice'.trx,
                    style: DT.titleMd(context).copyWith(fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: DT.divider(context)),
          const SizedBox(height: 12),
          Text(
            'These terms were last updated on March 9, 2026.'.trx,
            style: DT.sub(context).copyWith(fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
