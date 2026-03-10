import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/bookmark_model.dart';

class StorageService {
  static const String _bookmarksBoxName = 'bookmarks';
  static const String _settingsBoxName = 'settings';

  late Box _bookmarksBox;
  late Box _settingsBox;

  Future<void> init() async {
    _bookmarksBox = await Hive.openBox(_bookmarksBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Bookmarks
  Future<void> addBookmark(Bookmark bookmark) async {
    await _bookmarksBox.put(bookmark.id, jsonEncode(bookmark.toJson()));
  }

  Future<void> removeBookmark(String ayahId) async {
    await _bookmarksBox.delete(ayahId);
  }

  List<Bookmark> getAllBookmarks() {
    final bookmarks = <Bookmark>[];
    for (final key in _bookmarksBox.keys) {
      final data = jsonDecode(_bookmarksBox.get(key));
      bookmarks.add(Bookmark.fromJson(data));
    }
    return bookmarks..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool isBookmarked(String ayahId) {
    return _bookmarksBox.containsKey(ayahId);
  }

  // Settings
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T getSetting<T>(String key, T defaultValue) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _bookmarksBox.clear();
    await _settingsBox.clear();
  }
}
