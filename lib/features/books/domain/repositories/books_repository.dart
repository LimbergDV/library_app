import 'dart:io';
import '../entities/book_entity.dart';

/// Contrato del repositorio de libros.
abstract class BooksRepository {
  /// Obtiene todos los libros (GET /books).
  Future<List<BookEntity>> getBooks();

  /// Crea un nuevo libro con imagen opcional (POST /books).
  Future<BookEntity> createBook({
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  });

  /// Actualiza un libro existente (PUT /books).
  Future<BookEntity> updateBook({
    required String id,
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  });

  /// Elimina un libro por ID (DELETE /books/{id}).
  Future<bool> deleteBook(String id);
}
