import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

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
        extendBodyBehindAppBar: true,
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
              Icon(Icons.privacy_tip_outlined, color: DT.or, size: 18),
              const SizedBox(width: 7),
              Text(
                'Politique de Confidentialité'.trx,
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
                    const SizedBox(height: 16),
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildSummaryCard(context),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      number: '1',
                      title: 'Introduction'.trx,
                      content: 'privacy_intro'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '2',
                      title: 'Données Collectées'.trx,
                      children: [
                        _buildSubSection(
                          context,
                          title: '❌ Données NON collectées'.trx,
                          content: 'privacy_not_collected'.trx,
                        ),
                        _buildSubSection(
                          context,
                          title: '✅ Données utilisées localement'.trx,
                          content: 'privacy_local_data'.trx,
                        ),
                      ],
                    ),
                    _buildSection(
                      context,
                      number: '3',
                      title: 'Permissions Utilisées'.trx,
                      children: [
                        _buildPermissionTile(
                          context,
                          icon: Icons.location_on,
                          title: '📍 Localisation (GPS)'.trx,
                          why: 'privacy_location_why'.trx,
                          how: 'privacy_location_how'.trx,
                        ),
                        _buildPermissionTile(
                          context,
                          icon: Icons.wifi,
                          title: '🌐 Internet'.trx,
                          why: 'privacy_internet_why'.trx,
                          how: 'privacy_internet_how'.trx,
                        ),
                        _buildPermissionTile(
                          context,
                          icon: Icons.notifications,
                          title: '🔔 Notifications'.trx,
                          why: 'privacy_notifications_why'.trx,
                          how: 'privacy_notifications_how'.trx,
                        ),
                      ],
                    ),
                    _buildSection(
                      context,
                      number: '4',
                      title: 'Partage de Données'.trx,
                      content: 'privacy_sharing'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '5',
                      title: 'Services Tiers'.trx,
                      content: 'privacy_third_party'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '6',
                      title: 'Stockage des Données'.trx,
                      children: [
                        _buildInfoTile(
                          context,
                          title: 'Où sont stockées vos données ?'.trx,
                          content: 'privacy_storage_where'.trx,
                        ),
                        _buildInfoTile(
                          context,
                          title: 'Combien de temps ?'.trx,
                          content: 'privacy_storage_how_long'.trx,
                        ),
                      ],
                    ),
                    _buildSection(
                      context,
                      number: '7',
                      title: 'Sécurité'.trx,
                      content: 'privacy_security'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '8',
                      title: 'Droits des Utilisateurs'.trx,
                      content: 'privacy_rights'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '9',
                      title: 'Enfants et Vie Privée'.trx,
                      content: 'privacy_children'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '10',
                      title: 'Modifications de cette Politique'.trx,
                      content: 'privacy_changes'.trx,
                    ),
                    _buildSection(
                      context,
                      number: '11',
                      title: 'Contact'.trx,
                      content: 'privacy_contact'.trx,
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
                child: Icon(Icons.privacy_tip, color: DT.or, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔒 Politique de Confidentialité'.trx,
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
                  'privacyLastUpdated'.trx,
                  style: DT.sub(context).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DT.accent(context).withValues(alpha: 0.15),
            DT.accent(context).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DT.accent(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: DT.accent(context), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'En résumé'.trx,
                  style: DT.titleMd(context).copyWith(color: DT.accent(context)),
                ),
                const SizedBox(height: 8),
                Text(
                  'privacy_summary'.trx,
                  style: DT.titleMd(context).copyWith(fontWeight: FontWeight.w600),
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
                style: DT.titleMd(context).copyWith(height: 1.8, fontWeight: FontWeight.w400),
              ),
            if (children != null) ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DT.titleMd(context).copyWith(color: DT.accent(context), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: DT.titleMd(context).copyWith(height: 1.8, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String why,
    required String how,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DT.accent(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: DT.accent(context), size: 18),
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
          const SizedBox(height: 12),
          _buildDetailRow(context, label: 'Pourquoi ?'.trx, value: why),
          const SizedBox(height: 8),
          _buildDetailRow(context, label: 'Comment ?'.trx, value: how),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: DT.sub(context).copyWith(
              fontWeight: FontWeight.w600,
              color: DT.accent(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: DT.titleMd(context).copyWith(height: 1.5, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DT.titleMd(context).copyWith(color: DT.accent(context), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: DT.titleMd(context).copyWith(height: 1.8, fontWeight: FontWeight.w400),
          ),
        ],
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
              Text(
                'Résumé en une phrase'.trx,
                style: DT.titleMd(context),
              ),
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
                const Text('✅', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'privacy_footer'.trx,
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
            'Cette politique de confidentialité a été créée le 9 Mars 2026.'.trx,
            style: DT.sub(context).copyWith(fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
