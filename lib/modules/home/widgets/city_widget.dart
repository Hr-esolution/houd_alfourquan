import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/design_tokens.dart';
import '../../../core/controllers/language_controller.dart';
import '../controller/home_controller.dart';

class CityWidget extends GetView<HomeController> {
  const CityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'city_update',
      builder: (ctrl) {
        return GetBuilder<LanguageController>(
          builder: (langController) {
            return Glass(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // ── Icône localisation ─────────────────────────────────
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          DT.or.withValues(alpha: 0.18),
                          DT.or.withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: DT.or,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ── Ville + cache age ──────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ctrl.city,
                          style: DT.titleMd(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Builder(
                          builder: (_) => Text(
                            ctrl.isLoading ? 'Loading'.trx : ctrl.getCacheAge(),
                            style: DT.sub(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Séparateur vertical ────────────────────────────────
                  Container(
                    width: 1,
                    height: 28,
                    color: DT.or.withValues(alpha: 0.15),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),

                  // ── Bouton Changer ville ───────────────────────────────
                  GestureDetector(
                    onTap: () => _showCitySearchDialog(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: DT.or.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: DT.or.withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_location_alt_outlined,
                            color: DT.or,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Change'.trx,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: DT.or,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Bouton GPS ─────────────────────────────────────────
                  GestureDetector(
                    onTap: ctrl.isUpdatingLocation ? null : () => _useCurrentLocation(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: DT.accent(context).withValues(
                              alpha: ctrl.isUpdatingLocation ? 0.18 : 0.10,
                            ),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: DT.accent(context).withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: ctrl.isUpdatingLocation
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(DT.or),
                              ),
                            )
                          : Icon(
                              Icons.gps_fixed_rounded,
                              color: DT.accent(context),
                              size: 15,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _useCurrentLocation(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: DT.bg(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DT.borderColor(context), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(DT.or),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Locating'.trx,
                  style: DT.titleMd(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Getting GPS position'.trx,
                  style: DT.sub(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.40),
    );

    ctrl.useCurrentLocation().then((_) {
      if (Get.isDialogOpen == true) Get.back();
    });
  }

  void _showCitySearchDialog(BuildContext context) {
    Get.dialog(
      GetBuilder<HomeController>(
        builder: (ctrl) {
          return Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DT.bg(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DT.borderColor(context), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: DT.or,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            ctrl.searchCity(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search city...'.trx,
                            border: InputBorder.none,
                            hintStyle: DT.sub(context),
                          ),
                          autofocus: true,
                          style: DT.titleMd(context),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (ctrl.isSearching)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(DT.or),
                      ),
                    )
                  else if (ctrl.searchResults.isEmpty && ctrl.searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No city found'.trx,
                        style: DT.sub(context),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: ctrl.searchResults.length,
                        itemBuilder: (context, index) {
                          final result = ctrl.searchResults[index];
                          return ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: DT.or,
                            ),
                            title: Text(
                              result['display_name'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: DT.titleMd(context).copyWith(fontSize: 12),
                            ),
                            onTap: () async {
                              await ctrl.selectCity(result);
                              if (Get.isDialogOpen == true) {
                                Get.back();
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
