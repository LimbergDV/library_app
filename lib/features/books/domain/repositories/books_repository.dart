import 'dart:io';
import '../entities/book_entity.dart';


abstract class BooksRepository {
  Future<List<BookEntity>> getBooks();

  Future<BookEntity> createBook({
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  });

  Future<BookEntity> updateBook({
    required String id,
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  });

  Future<bool> deleteBook(String id);
}
