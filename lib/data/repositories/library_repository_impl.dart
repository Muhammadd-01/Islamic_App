import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/domain/entities/book.dart';
import 'package:islamic_app/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  @override
  Future<List<Book>> getBooks() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final String response = await rootBundle.loadString(
      'assets/api/library/books.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Book.fromJson(json)).toList();
  }

  @override
  Future<Book> getBookById(String id) async {
    final books = await getBooks();
    return books.firstWhere((book) => book.id == id);
  }
}

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepositoryImpl();
});

final booksListProvider = FutureProvider<List<Book>>((ref) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getBooks();
});
