import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/reciter_model.dart';
import '../models/surah_model.dart';

class ReciterController extends GetxController {
  late GetStorage _storage;
  late Dio _dio;

  // Data
  List<Reciter> _reciters = [];
  List<Surah> _surahs = [];
  String _selectedReciterId = '';
  Map<String, List<int>> _downloadedSurahs = {};
  final Map<String, String> _baseOverrides = {};
  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};
  double _totalUsedSpaceMb = 0;
  bool _isLoading = true;

  // Bulk download
  bool _isBulkDownloading = false;
  int _bulkProgressCurrent = 0;
  int _bulkProgressTotal = 114;
  bool _cancelDownload = false;

  // Getters
  List<Reciter> get reciters => _reciters;
  List<Surah> get surahs => _surahs;
  String get selectedReciterId => _selectedReciterId;
  bool get isLoading => _isLoading;

  Reciter? get selectedReciter {
    if (_reciters.isEmpty) return null;
    if (_selectedReciterId.isEmpty ||
        !_reciters.any((r) => r.id == _selectedReciterId)) {
      _selectedReciterId = _reciters.first.id;
      _storage.write('selected_reciter', _selectedReciterId);
    }
    try {
      return _reciters.firstWhere((r) => r.id == _selectedReciterId);
    } catch (e) {
      return _reciters.first;
    }
  }

  Map<String, List<int>> get downloadedSurahs => _downloadedSurahs;
  Map<int, double> get downloadProgress => _downloadProgress;
  Map<int, bool> get isDownloading => _isDownloading;
  double get totalUsedSpaceMb => _totalUsedSpaceMb;
  bool get isBulkDownloading => _isBulkDownloading;
  int get bulkProgressCurrent => _bulkProgressCurrent;
  int get bulkProgressTotal => _bulkProgressTotal;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    _storage = GetStorage();
    await _storage.initStorage;
    _dio = Dio();
    _surahs = Surah.generateDefaultSurahs();

    // Load reciters from cache
    _loadRecitersFromCache();
    _loadBaseOverrides();

    // Load selected reciter and downloads
    _loadSelectedReciter();
    _loadDownloadedSurahs();

    _isLoading = false;
    update();

    // Calculate space in background
    _calculateUsedSpace();
  }

  void _loadRecitersFromCache() {
    try {
      final cached = _storage.read('reciters_cache');
      if (cached != null) {
        final List<dynamic> data = jsonDecode(cached);
        _reciters = data.map((r) => Reciter.fromMap(r)).toList();
        update();
      }

      // If still empty, use defaults
      if (_reciters.isEmpty) {
        _loadDefaultReciters();
      }
    } catch (e) {
      debugPrint('Error loading reciters from cache: $e');
      _loadDefaultReciters();
    }
  }

  void _loadBaseOverrides() {
    try {
      final cached = _storage.read('reciter_base_overrides');
      if (cached != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          jsonDecode(cached),
        );
        _baseOverrides
          ..clear()
          ..addAll(data.map((k, v) => MapEntry(k, v.toString())));
      }
    } catch (e) {
      debugPrint('Error loading reciter base overrides: $e');
      _baseOverrides.clear();
    }
  }

  String _normalizeBaseUrl(String baseUrl) {
    if (baseUrl.isEmpty) return baseUrl;
    return baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  }

  String getResolvedBaseUrl(Reciter reciter) {
    // For alquran.cloud, we use the reciter identifier directly
    // The baseUrl field now stores the alquran.cloud edition identifier
    if (reciter.baseUrl.contains('cdn.islamic.network') || 
        reciter.baseUrl.startsWith('ar.')) {
      return reciter.baseUrl;
    }
    
    // Legacy: extract identifier from old mp3quran URLs
    final override = _baseOverrides[reciter.id];
    if (override != null && override.isNotEmpty) {
      return _normalizeBaseUrl(override);
    }
    return _normalizeBaseUrl(reciter.baseUrl);
  }

  void saveResolvedBaseUrl(String reciterId, String baseUrl) {
    if (reciterId.isEmpty || baseUrl.isEmpty) return;
    final normalized = _normalizeBaseUrl(baseUrl);
    _baseOverrides[reciterId] = normalized;
    _storage.write('reciter_base_overrides', jsonEncode(_baseOverrides));
  }

  void saveResolvedBaseUrlFromUrl(String reciterId, String url) {
    // Not needed for alquran.cloud CDN
  }

  /// Build audio URL using alquran.cloud API
  /// Returns the URL for the first ayah of the surah
  Future<String?> getAudioUrlForSurah(int surahNumber) async {
    final reciter = selectedReciter;
    if (reciter == null) return null;
    
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/surah/$surahNumber/${reciter.id}',
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final data = response.data['data'];
        final ayahs = data['ayahs'] as List?;
        if (ayahs != null && ayahs.isNotEmpty) {
          // Return the audio URL of the first ayah
          return ayahs.first['audio'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Error getting audio URL: $e');
    }
    return null;
  }

  /// Get all audio URLs for a surah (list of ayah URLs)
  Future<List<String>?> getAudioUrlsForSurah(int surahNumber) async {
    final reciter = selectedReciter;
    if (reciter == null) return null;
    
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/surah/$surahNumber/${reciter.id}',
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final data = response.data['data'];
        final ayahs = data['ayahs'] as List?;
        if (ayahs != null) {
          return ayahs
              .map((ayah) => ayah['audio'] as String)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error getting audio URLs: $e');
    }
    return null;
  }

  /// Get direct streaming URL from alquran.cloud (first ayah)
  Future<String?> getStreamingUrl(int surahNumber) async {
    return getAudioUrlForSurah(surahNumber);
  }

  void _loadDefaultReciters() {
    _reciters = [
      // Récitateurs les plus populaires (using alquran.cloud identifiers)
      // Total: 17 reciters available from alquran.cloud API
      Reciter(
        identifier: 'ar.alafasy',
        name: 'مشاري العفاسي',
        englishName: 'Mishary Alafasy',
        style: 'murattal',
        baseUrl: 'ar.alafasy',
      ),
      Reciter(
        identifier: 'ar.abdurrahmaansudais',
        name: 'عبد الرحمن السديس',
        englishName: 'Abdurrahman Al-Sudais',
        style: 'murattal',
        baseUrl: 'ar.abdurrahmaansudais',
      ),
      Reciter(
        identifier: 'ar.husary',
        name: 'محمود خليل الحصري',
        englishName: 'Mahmoud Khalil Al-Husary',
        style: 'murattal',
        baseUrl: 'ar.husary',
      ),
      Reciter(
        identifier: 'ar.husarymujawwad',
        name: 'محمود خليل الحصري (مجود)',
        englishName: 'Mahmoud Khalil Al-Husary (Mujawwad)',
        style: 'mujawwad',
        baseUrl: 'ar.husarymujawwad',
      ),
      Reciter(
        identifier: 'ar.mahermuaiqly',
        name: 'ماهر المعيقلي',
        englishName: 'Maher Al-Muaiqly',
        style: 'murattal',
        baseUrl: 'ar.mahermuaiqly',
      ),
      Reciter(
        identifier: 'ar.abdullahbasfar',
        name: 'عبد الله بصفر',
        englishName: 'Abdullah Basfar',
        style: 'murattal',
        baseUrl: 'ar.abdullahbasfar',
      ),
      Reciter(
        identifier: 'ar.saoodshuraym',
        name: 'سعود الشريم',
        englishName: 'Saud Al-Shuraim',
        style: 'murattal',
        baseUrl: 'ar.saoodshuraym',
      ),
      Reciter(
        identifier: 'ar.ahmedajamy',
        name: 'أحمد بن علي العجمي',
        englishName: 'Ahmed ibn Ali al-Ajmy',
        style: 'murattal',
        baseUrl: 'ar.ahmedajamy',
      ),
      Reciter(
        identifier: 'ar.hanirifai',
        name: 'هاني الرفاعي',
        englishName: 'Hani ar-Rifai',
        style: 'murattal',
        baseUrl: 'ar.hanirifai',
      ),
      Reciter(
        identifier: 'ar.hudhaify',
        name: 'علي الحذيفي',
        englishName: 'Ali Al-Hudhaify',
        style: 'murattal',
        baseUrl: 'ar.hudhaify',
      ),
      Reciter(
        identifier: 'ar.muhammadayyoub',
        name: 'محمد أيوب',
        englishName: 'Muhammad Ayyub',
        style: 'murattal',
        baseUrl: 'ar.muhammadayyoub',
      ),
      Reciter(
        identifier: 'ar.muhammadjibreel',
        name: 'محمد جبريل',
        englishName: 'Muhammad Jibreel',
        style: 'murattal',
        baseUrl: 'ar.muhammadjibreel',
      ),
      Reciter(
        identifier: 'ar.shaatree',
        name: 'أبو بكر الشاطري',
        englishName: 'Abu Bakr al-Shatri',
        style: 'murattal',
        baseUrl: 'ar.shaatree',
      ),
      Reciter(
        identifier: 'ar.ibrahimakhbar',
        name: 'إبراهيم الأخضر',
        englishName: 'Ibrahim Al-Akhdar',
        style: 'murattal',
        baseUrl: 'ar.ibrahimakhbar',
      ),
      Reciter(
        identifier: 'ar.aymanswoaid',
        name: 'أيمن سويد',
        englishName: 'Ayman Suwaid',
        style: 'murattal',
        baseUrl: 'ar.aymanswoaid',
      ),
      Reciter(
        identifier: 'ar.abdulsamad',
        name: 'عبد الباسط عبد الصمد',
        englishName: 'Abdul Basit (Murattal)',
        style: 'murattal',
        baseUrl: 'ar.abdulsamad',
      ),
      Reciter(
        identifier: 'ar.parhizgar',
        name: 'شهریاریز پرهیزگار',
        englishName: 'Parhizgar',
        style: 'murattal',
        baseUrl: 'ar.parhizgar',
      ),
    ];
    update();
  }

  void _loadSelectedReciter() {
    _selectedReciterId = _storage.read('selected_reciter') ?? '';
    if (_selectedReciterId.isEmpty && _reciters.isNotEmpty) {
      _selectedReciterId = _reciters.first.id;
      _storage.write('selected_reciter', _selectedReciterId);
    }
  }

  void _loadDownloadedSurahs() {
    final downloadedMap = _storage.read('downloaded_map');
    if (downloadedMap != null) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        jsonDecode(downloadedMap),
      );
      _downloadedSurahs = data.map((key, value) {
        return MapEntry(key, (value as List).map((e) => e as int).toList());
      });
    }
  }

  Future<void> selectReciter(String id) async {
    if (!_reciters.any((r) => r.id == id)) {
      Get.snackbar('Error', 'Reciter not found');
      return;
    }
    _selectedReciterId = id;
    await _storage.write('selected_reciter', id);
    _calculateUsedSpace();
    update();
    // Removed snackbar from here - it's now called in ReciterListPage after navigation
  }

  Future<void> downloadSurah(int surahNumber) async {
    final reciter = selectedReciter;
    if (reciter == null) {
      Get.snackbar('Error', 'Please select a reciter first');
      return;
    }

    // Check permissions for Android < 10
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final requested = await Permission.storage.request();
        if (!requested.isGranted) {
          Get.snackbar('Permission Denied', 'Storage permission is required');
          return;
        }
      }
    }

    try {
      _isDownloading[surahNumber] = true;
      _downloadProgress[surahNumber] = 0.0;
      update(['download_$surahNumber']);

      final directory = await getApplicationDocumentsDirectory();
      final reciterDir = Directory('${directory.path}/quran/${reciter.id}');
      if (!await reciterDir.exists()) {
        await reciterDir.create(recursive: true);
      }

      final paddedNumber = surahNumber.toString().padLeft(3, '0');
      final filePath = '${reciterDir.path}/$paddedNumber.mp3';
      
      // Get all ayah URLs for this surah
      final ayahUrls = await getAudioUrlsForSurah(surahNumber);
      if (ayahUrls == null || ayahUrls.isEmpty) {
        throw Exception('No available audio source');
      }

      // Download all ayahs
      final tempFiles = <File>[];
      
      for (int i = 0; i < ayahUrls.length; i++) {
        final url = ayahUrls[i];
        final tempFile = File('${directory.path}/temp_ayah_${surahNumber}_$i.mp3');
        tempFiles.add(tempFile);
        
        debugPrint('Downloading ayah ${i + 1}/${ayahUrls.length}: $url');
        
        await _dio.download(
          url,
          tempFile.path,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              _downloadProgress[surahNumber] = (i + received / total) / ayahUrls.length;
              update(['download_$surahNumber']);
            }
          },
        );
      }
      
      // For now, just use the first ayah file as the surah file
      // Note: Full audio concatenation requires additional processing
      if (tempFiles.isNotEmpty) {
        await tempFiles.first.copy(filePath);
      }
      
      // Clean up temp files
      for (final f in tempFiles) {
        if (await f.exists()) await f.delete();
      }
      
      // Save to downloaded list
      if (!_downloadedSurahs.containsKey(reciter.id)) {
        _downloadedSurahs[reciter.id] = [];
      }
      if (!_downloadedSurahs[reciter.id]!.contains(surahNumber)) {
        _downloadedSurahs[reciter.id]!.add(surahNumber);
        await _storage.write('downloaded_map', jsonEncode(_downloadedSurahs));
      }

      _isDownloading[surahNumber] = false;
      _downloadProgress[surahNumber] = 1.0;
      _calculateUsedSpace();
      update(['download_$surahNumber']);

      Get.snackbar('Success', 'Surah $surahNumber downloaded');
    } catch (e) {
      _isDownloading[surahNumber] = false;
      _downloadProgress[surahNumber] = 0.0;
      update(['download_$surahNumber']);
      debugPrint('Download error: $e');
      Get.snackbar('Error', 'Failed: ${e.toString()}');
    }
  }

  String _buildAudioUrl(Reciter reciter, int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');

    // Use baseUrl directly
    final base = getResolvedBaseUrl(reciter);
    if (base.isNotEmpty) {
      return '$base$padded.mp3';
    }

    // Ultimate fallback to Mishary Alafasy
    return 'https://server8.mp3quran.net/afs/$padded.mp3';
  }

  Future<void> deleteSurah(int surahNumber) async {
    if (_selectedReciterId.isEmpty) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/quran/$_selectedReciterId/${surahNumber.toString().padLeft(3, '0')}.mp3';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      if (_downloadedSurahs.containsKey(_selectedReciterId)) {
        _downloadedSurahs[_selectedReciterId]!.remove(surahNumber);
        await _storage.write('downloaded_map', jsonEncode(_downloadedSurahs));
      }

      _downloadProgress.remove(surahNumber);
      _calculateUsedSpace();
      update(['download_$surahNumber']);

      Get.snackbar('Success', 'Surah $surahNumber deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed: ${e.toString()}');
    }
  }

  bool isDownloaded(int surahNumber) {
    if (_selectedReciterId.isEmpty) return false;
    final surahs = _downloadedSurahs[_selectedReciterId];
    return surahs != null && surahs.contains(surahNumber);
  }

  Future<String> getLocalPath(int surahNumber) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/quran/$_selectedReciterId/${surahNumber.toString().padLeft(3, '0')}.mp3';
  }

  String getRemoteUrl(int surahNumber) {
    final reciter = selectedReciter;
    if (reciter == null) return '';
    return _buildAudioUrl(reciter, surahNumber);
  }

  Future<void> _calculateUsedSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final quranDir = Directory('${directory.path}/quran');

      if (!await quranDir.exists()) {
        _totalUsedSpaceMb = 0;
        update();
        return;
      }

      int totalBytes = 0;
      await for (var entity in quranDir.list(recursive: true)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }

      _totalUsedSpaceMb = totalBytes / (1024 * 1024);
      update();
    } catch (e) {
      _totalUsedSpaceMb = 0;
      update();
    }
  }

  Future<void> downloadAllSequential() async {
    if (_isBulkDownloading) return;

    _isBulkDownloading = true;
    _bulkProgressCurrent = 0;
    _bulkProgressTotal = 114;
    _cancelDownload = false;
    update(['bulk_download']);

    for (int i = 1; i <= 114; i++) {
      if (_cancelDownload) {
        _isBulkDownloading = false;
        update(['bulk_download']);
        Get.snackbar('Cancelled', 'Download cancelled');
        return;
      }

      if (!isDownloaded(i)) {
        _bulkProgressCurrent = i;
        update(['bulk_download']);
        await downloadSurah(i);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    _isBulkDownloading = false;
    _bulkProgressCurrent = 114;
    update(['bulk_download']);
    Get.snackbar('Complete', 'All surahs downloaded');
  }

  void cancelBulkDownload() {
    _cancelDownload = true;
  }

  Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result.any(
      (r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile,
    );
  }

  Future<void> refreshReciters() async {
    debugPrint('🔄 Refreshing reciters from API...');
    try {
      // Get all audio editions that are versebyverse type in Arabic
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/edition?format=audio&language=ar&type=versebyverse',
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> editions = response.data['data'];
        final reciterList = <Reciter>[];

        for (var edition in editions) {
          final identifier = edition['identifier'] as String? ?? '';
          final name = edition['name'] as String? ?? '';
          final englishName = edition['englishName'] as String? ?? '';
          final lang = edition['language'] as String? ?? '';
          final type = edition['type'] as String? ?? '';
          final format = edition['format'] as String? ?? '';

          // Only include Arabic audio editions
          if (lang != 'ar' || type != 'versebyverse' || format != 'audio') {
            continue;
          }

          reciterList.add(Reciter(
            identifier: identifier,
            name: name,
            englishName: englishName.isNotEmpty ? englishName : name,
            style: 'murattal',
            baseUrl: identifier, // Store the identifier for API calls
          ));
        }

        // Sort by English name
        reciterList.sort(
          (a, b) => a.englishName.compareTo(b.englishName),
        );

        _reciters = reciterList;
        
        // Cache the reciters
        final reciterMap = reciterList.map((r) => r.toMap()).toList();
        await _storage.write('reciters_cache', jsonEncode(reciterMap));
        
        // Set first reciter as default if none selected
        if (_reciters.isNotEmpty && _selectedReciterId.isEmpty) {
          _selectedReciterId = _reciters.first.id;
          await _storage.write('selected_reciter', _selectedReciterId);
        }
        
        update();
        Get.snackbar('Success', 'Reciters updated (${reciterList.length} found)');
      }
    } catch (e) {
      debugPrint('Error refreshing reciters: $e');
      Get.snackbar('Error', 'Failed to refresh reciters');
    }
  }

  Future<void> resetRecitersCache() async {
    await _storage.remove('reciters_cache');
    await _storage.remove('selected_reciter');
    _reciters = [];
    _selectedReciterId = '';
    _loadDefaultReciters();
    update();
    Get.snackbar('Reset', 'Reciters cache cleared. Restart app to reload.');
  }
}
