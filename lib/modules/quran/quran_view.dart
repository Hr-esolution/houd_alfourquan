import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/reciter_controller.dart';
import 'controllers/quran_controller.dart';
import 'controllers/player_controller.dart';
import 'views/surah_list_page.dart';

class QuranView extends StatelessWidget {
  const QuranView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(QuranController());
    Get.put(ReciterController());

    return GetBuilder<ReciterController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Quran data...'),
                ],
              ),
            ),
          );
        }

        // Initialize PlayerController after ReciterController is loaded
        if (!Get.isRegistered<PlayerController>()) {
          Get.put(PlayerController());
        }

        return const SurahListPage();
      },
    );
  }
}
