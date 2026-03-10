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

  static const Map<String, List<String>> _baseAliases = {
    'ar.saadalghamdi': [
      'https://server6.mp3quran.net/ghamdi/',
      'https://server7.mp3quran.net/s_gmd/',
    ],
    'ar.saadalghaamdi': [
      'https://server6.mp3quran.net/ghamdi/',
      'https://server7.mp3quran.net/s_gmd/',
    ],
    'ar.sa3d_alghaamdi': [
      'https://server6.mp3quran.net/ghamdi/',
      'https://server7.mp3quran.net/s_gmd/',
    ],
    'ar.minshawi': [
      'https://server10.mp3quran.net/minsh/',
    ],
  };

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
    if (_selectedReciterId.isEmpty || !_reciters.any((r) => r.id == _selectedReciterId)) {
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
        final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(cached));
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
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final path = uri.path;
    final lastSlash = path.lastIndexOf('/');
    if (lastSlash < 0) return;
    final basePath = path.substring(0, lastSlash + 1);
    final baseUrl = uri.replace(path: basePath, query: '').toString();
    saveResolvedBaseUrl(reciterId, baseUrl);
  }

  List<String> buildCandidateUrls(int surahNumber) {
    final reciter = selectedReciter;
    if (reciter == null) return [];
    final padded = surahNumber.toString().padLeft(3, '0');
    final base = getResolvedBaseUrl(reciter);
    if (base.isEmpty) return [];

    final urls = <String>[];
    final seen = <String>{};

    void addBase(String candidateBase) {
      final normalized = _normalizeBaseUrl(candidateBase);
      final url = '${normalized}$padded.mp3';
      if (seen.add(url)) {
        urls.add(url);
      }
    }

    addBase(base);

    final uri = Uri.tryParse(base);
    if (uri != null && uri.host.endsWith('mp3quran.net')) {
      const servers = [
        'server8',
        'server9',
        'server10',
        'server11',
        'server12',
        'server13',
        'server7',
        'server6',
      ];
      for (final server in servers) {
        final host = '$server.mp3quran.net';
        if (host == uri.host) continue;
        final candidate = uri.replace(host: host).toString();
        addBase(candidate);
      }
    }

    final aliases = _baseAliases[reciter.id] ?? const [];
    for (final alias in aliases) {
      addBase(alias);
    }

    return urls;
  }

  void _loadDefaultReciters() {
    _reciters = [
      // Récitateurs les plus populaires
      Reciter(identifier: 'ar.alafasy', name: 'مشاري العفاسي', englishName: 'Mishary Alafasy', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/afs/'),
      Reciter(identifier: 'ar.sudais', name: 'عبد الرحمن السديس', englishName: 'Abdurrahman Al-Sudais', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/swd/'),
      Reciter(identifier: 'ar.husary', name: 'محمود خليل الحصري', englishName: 'Mahmoud Khalil Al-Husary', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/husr/'),
      Reciter(identifier: 'ar.minshawi', name: 'محمد صديق المنشاوي', englishName: 'Mohamed Siddiq El-Minshawi', style: 'murattal', baseUrl: 'https://server10.mp3quran.net/minsh/'),
      Reciter(identifier: 'ar.mahermuaiqly', name: 'ماهر المعيقلي', englishName: 'Maher Al-Muaiqly', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/maher/'),
      Reciter(identifier: 'ar.abdulbasitmurattal', name: 'عبد الباسط عبد الصمد', englishName: 'Abdul Basit (Murattal)', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/basit/'),
      Reciter(identifier: 'ar.saoodshuraim', name: 'سعود الشريم', englishName: 'Saud Al-Shuraim', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/shur/'),
      Reciter(identifier: 'ar.ahmedajmy', name: 'أحمد بن علي العجمي', englishName: 'Ahmed ibn Ali al-Ajmy', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/ajmy/'),
      
      // Autres récitateurs populaires
      Reciter(identifier: 'ar.hanirifai', name: 'هاني الرفاعي', englishName: 'Hani ar-Rifai', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/rifai/'),
      Reciter(identifier: 'ar.husarymujawwad', name: 'محمود خليل الحصري (مجود)', englishName: 'Mahmoud Khalil Al-Husary (Mujawwad)', style: 'mujawwad', baseUrl: 'https://server8.mp3quran.net/husr_m/'),
      Reciter(identifier: 'ar.abdullahbasfar', name: 'عبد الله بصفر', englishName: 'Abdullah Basfar', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/basfar/'),
      Reciter(identifier: 'ar.abdulmuhsinalqasim', name: 'عبد المحسن القاسم', englishName: 'AbdulMuhsin Al-Qasim', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/qasim/'),
      Reciter(identifier: 'ar.abuubakralshatri', name: 'أبو بكر الشاطري', englishName: 'Abu Bakr al-Shatri', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/shatri/'),
      Reciter(identifier: 'ar.hudhaify', name: 'علي الحذيفي', englishName: 'Ali Al-Hudhaify', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/hudh/'),
      Reciter(identifier: 'ar.yasseraldosari', name: 'ياسر الدوسري', englishName: 'Yasser Al-Dosari', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/yasser/'),
      Reciter(identifier: 'ar.mohammadsaleemajid', name: 'محمد سليم', englishName: 'Mohammad Saleem', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/saleem/'),
      Reciter(identifier: 'ar.muhammadayyoub', name: 'محمد أيوب', englishName: 'Muhammad Ayyub', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/ayoub/'),
      Reciter(identifier: 'ar.muhammadjibreel', name: 'محمد جبريل', englishName: 'Muhammad Jibreel', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/jibr/'),
      Reciter(identifier: 'ar.saadalghamdi', name: 'سعد الغامدي', englishName: 'Saad Al-Ghamdi', style: 'murattal', baseUrl: 'https://server6.mp3quran.net/ghamdi/'),
      Reciter(identifier: 'ar.sahlalalawi', name: 'سهل الياسين', englishName: 'Sahl Al-Yassin', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/sahl/'),
      Reciter(identifier: 'ar.salahalbudeair', name: 'صلاح البدير', englishName: 'Salah Al-Budeair', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/salah/'),
      Reciter(identifier: 'ar.faresabbad', name: 'فارس عباد', englishName: 'Fares Abbad', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/abbad/'),
      Reciter(identifier: 'ar.nasserqatami', name: 'ناصر القطامي', englishName: 'Nasser Al-Qatami', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/qatami/'),
      
      // Récitateurs additionnels
      Reciter(identifier: 'ar.ibrahimakhbar', name: 'إبراهيم الأخضر', englishName: 'Ibrahim Al-Akhdar', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/akhdar/'),
      Reciter(identifier: 'ar.khalilalhusary', name: 'محمود خليل الحصري', englishName: 'Khalil Al-Husary', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/husr/'),
      Reciter(identifier: 'ar.abdulbasitmujawwad', name: 'عبد الباسط عبد الصمد (مجود)', englishName: 'Abdul Basit (Mujawwad)', style: 'mujawwad', baseUrl: 'https://server8.mp3quran.net/basit_m/'),
      Reciter(identifier: 'ar.aymansueed', name: 'أيمن سويد', englishName: 'Ayman Suwaid', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/suwaid/'),
      Reciter(identifier: 'ar.abdurrahmaanmaash', name: 'عبد الرحمن معاش', englishName: 'Abdul Rahman Maash', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/maash/'),
      Reciter(identifier: 'ar.aliabdurrahmaan', name: 'علي عبد الرحمن', englishName: 'Ali Abdur-Rahman', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/hudh/'),
      Reciter(identifier: 'ar.faresabbaad', name: 'فارس عباد', englishName: 'Fares Abbad', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/abbad/'),
      Reciter(identifier: 'ar.hazaabalbalami', name: 'حازم الحازمي', englishName: 'Hazem Al-Hazmi', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/hazmi/'),
      Reciter(identifier: 'ar.khalidqahtani', name: 'خالد القحطاني', englishName: 'Khalid Al-Qahtani', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/qahtani/'),
      Reciter(identifier: 'ar.muhammadmuhsin', name: 'محمد محسن', englishName: 'Muhammad Muhsin', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/muhsin/'),
      Reciter(identifier: 'ar.saadalghaamdi', name: 'سعد الغامدي', englishName: 'Saad Al-Ghamdi', style: 'murattal', baseUrl: 'https://server6.mp3quran.net/ghamdi/'),
      Reciter(identifier: 'ar.suoodshuraym', name: 'سعود الشريم', englishName: 'Saud Al-Shuraim', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/shur/'),
      Reciter(identifier: 'ar.yasseralkahtani', name: 'ياسر القحطاني', englishName: 'Yasser Al-Kahtani', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/kahtani/'),
      Reciter(identifier: 'ar.abdullaahkhalifa', name: 'عبد الله خليفة', englishName: 'Abdullah Khalifa', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/khalifa/'),
      Reciter(identifier: 'ar.abdulwahhab', name: 'عبد الوهاب الطريري', englishName: 'Abdul Wahhab Al-Tariri', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/tariri/'),
      Reciter(identifier: 'ar.haniarrefaee', name: 'هاني الرفاعي', englishName: 'Hani Ar-Rifai', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/rifai/'),
      Reciter(identifier: 'ar.husarychildren', name: 'الحصري (أطفال)', englishName: 'Al-Husary (Children)', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/husr_children/'),
      Reciter(identifier: 'ar.jabri', name: 'محمد جبريل', englishName: 'Muhammad Jibril', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/jibr/'),
      Reciter(identifier: 'ar.mishaari', name: 'مشاري العفاسي', englishName: 'Mishary Rashid Alafasy', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/afs/'),
      Reciter(identifier: 'ar.muhammadaiyoob', name: 'محمد أيوب', englishName: 'Muhammad Ayyub', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/ayoub/'),
      Reciter(identifier: 'ar.muhammadjibreel', name: 'محمد جبريل', englishName: 'Muhammad Jibreel', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/jibr/'),
      Reciter(identifier: 'ar.sa3d_alghaamdi', name: 'سعد الغامدي', englishName: 'Saad Al-Ghamdi', style: 'murattal', baseUrl: 'https://server6.mp3quran.net/ghamdi/'),
      Reciter(identifier: 'ar.shaatree', name: 'أبو بكر الشاطري', englishName: 'Abu Bakr Ash-Shaatree', style: 'murattal', baseUrl: 'https://server8.mp3quran.net/shatri/'),
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
      final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(downloadedMap));
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
      final candidates = buildCandidateUrls(surahNumber);
      if (candidates.isEmpty) {
        throw Exception('No available audio source');
      }

      Object? lastError;
      for (final url in candidates) {
        try {
          debugPrint('Downloading: $url');
          await _dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                _downloadProgress[surahNumber] = received / total;
                update(['download_$surahNumber']);
              }
            },
          );
          saveResolvedBaseUrlFromUrl(reciter.id, url);
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      if (lastError != null) {
        throw lastError;
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
      return '${base}$padded.mp3';
    }

    // Ultimate fallback to Mishary Alafasy
    return 'https://server8.mp3quran.net/afs/$padded.mp3';
  }

  Future<void> deleteSurah(int surahNumber) async {
    if (_selectedReciterId.isEmpty) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/quran/$_selectedReciterId/${surahNumber.toString().padLeft(3, '0')}.mp3';
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
    return result.any((r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile);
  }

  Future<void> refreshReciters() async {
    debugPrint('🔄 Refreshing reciters from API...');
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/edition?format=audio&language=ar',
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> editions = data['data'];
          final reciterList = <Map<String, dynamic>>[];

          // Map API identifiers to mp3quran base URLs
          final mp3quranUrls = <String, String>{
            'ar.alafasy': 'https://server8.mp3quran.net/afs/',
            'ar.sudais': 'https://server8.mp3quran.net/swd/',
            'ar.husary': 'https://server8.mp3quran.net/husr/',
            'ar.minshawi': 'https://server10.mp3quran.net/minsh/',
            'ar.mahermuaiqly': 'https://server8.mp3quran.net/maher/',
            'ar.abdulbasitmurattal': 'https://server8.mp3quran.net/basit/',
            'ar.saoodshuraim': 'https://server8.mp3quran.net/shur/',
            'ar.ahmedajmy': 'https://server8.mp3quran.net/ajmy/',
            'ar.hanirifai': 'https://server8.mp3quran.net/rifai/',
            'ar.husarymujawwad': 'https://server8.mp3quran.net/husr_m/',
            'ar.khalilhusarymujawwad': 'https://server8.mp3quran.net/husr_m/',
            'ar.abdullahbasfar': 'https://server8.mp3quran.net/basfar/',
            'ar.abdulmuhsinalqasim': 'https://server8.mp3quran.net/qasim/',
            'ar.abuubakralshatri': 'https://server8.mp3quran.net/shatri/',
            'ar.hudhaify': 'https://server8.mp3quran.net/hudh/',
            'ar.yasseraldosari': 'https://server8.mp3quran.net/yasser/',
            'ar.mohammadsaleemajid': 'https://server8.mp3quran.net/saleem/',
            'ar.muhammadayyoub': 'https://server8.mp3quran.net/ayoub/',
            'ar.muhammadjibreel': 'https://server8.mp3quran.net/jibr/',
            'ar.saadalghamdi': 'https://server6.mp3quran.net/ghamdi/',
            'ar.sahlalalawi': 'https://server8.mp3quran.net/sahl/',
            'ar.salahalbudeair': 'https://server8.mp3quran.net/salah/',
            'ar.faresabbad': 'https://server8.mp3quran.net/abbad/',
            'ar.nasserqatami': 'https://server8.mp3quran.net/qatami/',
            'ar.ibrahimakhbar': 'https://server8.mp3quran.net/akhdar/',
            'ar.aymansueed': 'https://server8.mp3quran.net/suwaid/',
            'ar.abdurrahmaanmaash': 'https://server8.mp3quran.net/maash/',
            'ar.hazaabalbalami': 'https://server8.mp3quran.net/hazmi/',
            'ar.khalidqahtani': 'https://server8.mp3quran.net/qahtani/',
            'ar.muhammadmuhsin': 'https://server8.mp3quran.net/muhsin/',
            'ar.abdullaahkhalifa': 'https://server8.mp3quran.net/khalifa/',
            'ar.abdulwahhab': 'https://server8.mp3quran.net/tariri/',
            'ar.husarychildren': 'https://server8.mp3quran.net/husr_children/',
          };

          for (var edition in editions) {
            final identifier = edition['identifier'] as String? ?? '';
            final name = edition['name'] as String? ?? '';
            final englishName = edition['englishName'] as String? ?? '';
            final lang = edition['language'] as String? ?? '';
            final type = edition['type'] as String? ?? '';
            final format = edition['format'] as String? ?? '';

            if (lang != 'ar' || type != 'versebyverse' || format != 'audio') continue;

            final baseUrl = mp3quranUrls[identifier] ?? '';

            reciterList.add({
              'identifier': identifier,
              'name': name,
              'englishName': englishName.isNotEmpty ? englishName : name,
              'style': 'murattal',
              'baseUrl': baseUrl,
            });
          }

          reciterList.sort((a, b) =>
            (a['englishName'] as String).compareTo(b['englishName'] as String));

          _reciters = reciterList.map((r) => Reciter.fromMap(r)).toList();
          await _storage.write('reciters_cache', jsonEncode(reciterList));
          update();
          Get.snackbar('Success', 'Reciters updated');
        }
      }
    } catch (e) {
      debugPrint('Error refreshing reciters: $e');
      Get.snackbar('Error', 'Failed to refresh');
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
