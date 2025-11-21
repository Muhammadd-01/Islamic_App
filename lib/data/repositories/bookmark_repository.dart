import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/domain/entities/bookmark.dart';

class BookmarkRepository {
  static const String _key = 'bookmarks';

  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Bookmark.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final bookmarks = await getBookmarks();
    // Check if already exists
    if (bookmarks.any((b) => b.id == bookmark.id && b.type == bookmark.type)) {
      return;
    }

    bookmarks.add(bookmark);
    await _saveBookmarks(bookmarks);
  }

  Future<void> removeBookmark(String id, String type) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.id == id && b.type == type);
    await _saveBookmarks(bookmarks);
  }

  Future<bool> isBookmarked(String id, String type) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b.id == id && b.type == type);
  }

  Future<void> _saveBookmarks(List<Bookmark> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(
      bookmarks.map((b) => b.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }
}

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

final bookmarksProvider = FutureProvider<List<Bookmark>>((ref) async {
  final repo = ref.watch(bookmarkRepositoryProvider);
  return repo.getBookmarks();
});
