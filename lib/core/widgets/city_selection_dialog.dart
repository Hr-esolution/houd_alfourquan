import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/location_service.dart';

/// City Selection Dialog
///
/// Allows manual city selection when GPS detection fails
/// or user prefers to choose manually.
class CitySelectionDialog extends StatelessWidget {
  final LocationService _locationService = LocationService();

  CitySelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final isSearching = false.obs;
    final searchResults = <CitySearchResult>[].obs;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sélectionner une ville',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une ville...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) async {
                if (value.length < 2) {
                  searchResults.clear();
                  return;
                }

                isSearching.value = true;

                try {
                  final results = await _locationService.searchCities(value);
                  searchResults.value = results;
                } catch (e) {
                  debugPrint('❌ Search error: $e');
                } finally {
                  isSearching.value = false;
                }
              },
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: Obx(() {
                if (isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_searching,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchController.text.isEmpty
                              ? 'Recherchez une ville'
                              : 'Aucune ville trouvée',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final result = searchResults[index];
                    return ListTile(
                      leading: Icon(
                        Icons.location_city,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        result.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        result.country,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(result),
                    );
                  },
                );
              }),
            ),

            // Footer
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(null),
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Utiliser ma position actuelle'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show city selection dialog and return selected result
Future<CitySearchResult?> showCitySelectionDialog(BuildContext context) async {
  return showDialog<CitySearchResult>(
    context: context,
    builder: (context) => CitySelectionDialog(),
  );
}
