import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../controllers/reciter_controller.dart';

class PlayerController extends GetxController {
  late AudioPlayer _audioPlayer;
  late ReciterController _reciterController;

  int _currentSurah = 0;
  bool _isPlaying = false;
  double _speed = 1.0;
  bool _isInitialized = false;

  // Getters
  int get currentSurah => _currentSurah;
  bool get isPlaying => _isPlaying;
  double get speed => _speed;
  bool get isInitialized => _isInitialized;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    _reciterController = Get.find<ReciterController>();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.setSpeed(_speed);
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      update();
    });
    _audioPlayer.positionStream.listen((position) {
      // Can be used for progress tracking
    });
    _isInitialized = true;
    update();
  }

  Future<void> playOrStream(int surahNumber) async {
    try {
      _currentSurah = surahNumber;
      update();

      final isDownloaded = _reciterController.isDownloaded(surahNumber);

      if (isDownloaded) {
        // Play from local file
        await _playLocal(surahNumber);
      } else {
        // Stream from remote
        await _streamFromRemote(surahNumber);
      }
    } catch (e) {
      debugPrint('❌ Play error: $e');
      Get.snackbar('Error', 'Failed to play: ${e.toString()}');
    }
  }

  Future<void> _playLocal(int surahNumber) async {
    try {
      final path = await _reciterController.getLocalPath(surahNumber);
      final file = File(path);

      if (await file.exists()) {
        debugPrint('✅ Playing local: $path');
        await _audioPlayer.setFilePath(path);
        await _audioPlayer.play();
      } else {
        debugPrint('⚠️ Local file not found, streaming...');
        await _streamFromRemote(surahNumber);
      }
    } catch (e) {
      debugPrint('❌ Local play error: $e');
      await _streamFromRemote(surahNumber);
    }
  }

  Future<void> _streamFromRemote(int surahNumber) async {
    try {
      final candidates = _reciterController.buildCandidateUrls(surahNumber);
      if (candidates.isEmpty) {
        Get.snackbar('Error', 'No reciter selected');
        return;
      }

      Object? lastError;
      for (final url in candidates) {
        try {
          debugPrint('📡 Streaming from: $url');
          await _audioPlayer.setUrl(url);
          await _audioPlayer.play();

          final reciterId = _reciterController.selectedReciterId;
          if (reciterId.isNotEmpty) {
            _reciterController.saveResolvedBaseUrlFromUrl(reciterId, url);
          }

          Get.snackbar(
            'Streaming',
            'Playing Surah $surahNumber from ${_reciterController.selectedReciter?.nameFr}',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          return;
        } catch (e) {
          lastError = e;
        }
      }

      debugPrint('❌ Stream error: $lastError');
      Get.snackbar('Error', 'Failed to stream: ${lastError ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('❌ Stream error: $e');
      Get.snackbar('Error', 'Failed to stream: ${e.toString()}');
    }
  }

  Future<void> playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_currentSurah > 0) {
        await _audioPlayer.play();
      }
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSurah = 0;
    update();
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _audioPlayer.setSpeed(speed);
    update();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
