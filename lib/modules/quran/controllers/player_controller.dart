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
  String _currentReciterName = '';
  String _currentReciterId = '';

  // Getters
  int get currentSurah => _currentSurah;
  bool get isPlaying => _isPlaying;
  double get speed => _speed;
  bool get isInitialized => _isInitialized;
  String get currentReciterName => _currentReciterName;
  String get currentReciterId => _currentReciterId;

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
      // Wait for reciters to load if needed
      if (_reciterController.isLoading) {
        Get.snackbar(
          'Loading',
          'Please wait, loading reciters...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if reciters list is empty
      if (_reciterController.reciters.isEmpty) {
        Get.snackbar(
          'Error',
          'No reciters available. Please refresh the app.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _currentSurah = surahNumber;

      // Store the current reciter info at the time of playing
      final reciter = _reciterController.selectedReciter;
      if (reciter == null) {
        Get.snackbar(
          'Error',
          'Please select a reciter first',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      _currentReciterName = reciter.translatedName;
      _currentReciterId = reciter.id;
      
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
      // Use the stored reciter ID to build URLs
      if (_currentReciterId.isEmpty) {
        Get.snackbar('Error', 'No reciter selected');
        return;
      }

      // Get all ayah URLs for this surah from alquran.cloud API
      final ayahUrls = await _reciterController.getAudioUrlsForSurah(surahNumber);
      if (ayahUrls == null || ayahUrls.isEmpty) {
        Get.snackbar('Error', 'No audio source available');
        return;
      }

      try {
        debugPrint('📡 Streaming surah $surahNumber with ${ayahUrls.length} ayahs');

        // Create a list of audio sources for all ayahs
        final audioSources = ayahUrls
            .map((url) => AudioSource.uri(Uri.parse(url)))
            .toList();

        // ignore: deprecated_member_use
        await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: audioSources));
        await _audioPlayer.play();

        // Use the stored reciter name instead of fetching from selectedReciter
        Get.snackbar(
          'Streaming',
          'Playing Surah $surahNumber from $_currentReciterName',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        debugPrint('❌ Stream error: $e');
        Get.snackbar(
          'Error',
          'Audio not available for this reciter. Try another reciter.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
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
