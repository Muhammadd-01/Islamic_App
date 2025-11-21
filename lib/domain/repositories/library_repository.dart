import 'package:islamic_app/domain/entities/book.dart';

abstract class LibraryRepository {
  Future<List<Book>> getBooks();
  Future<Book> getBookById(String id);
}
