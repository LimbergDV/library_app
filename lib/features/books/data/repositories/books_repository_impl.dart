import 'dart:io';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/books_repository.dart';
import '../datasources/books_remote_datasource.dart';

/// Implementación concreta del repositorio de libros.
/// Actúa como adaptador: convierte BookModel (data) → BookEntity (domain).
class BooksRepositoryImpl implements BooksRepository {
  final BooksRemoteDatasource remoteDatasource;

  const BooksRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<BookEntity>> getBooks() async {
    final models = await remoteDatasource.getBooks();
    // Los modelos extienden entidades, se puede retornar directamente
    return models;
  }

  @override
  Future<BookEntity> createBook({
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) async {
    return remoteDatasource.createBook(
      title: title,
      author: author,
      editorial: editorial,
      numberOfPages: numberOfPages,
      backgroundColor: backgroundColor,
      imageFile: imageFile,
    );
  }

  @override
  Future<BookEntity> updateBook({
    required String id,
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) async {
    return remoteDatasource.updateBook(
      id: id,
      title: title,
      author: author,
      editorial: editorial,
      numberOfPages: numberOfPages,
      backgroundColor: backgroundColor,
      imageFile: imageFile,
    );
  }

  @override
  Future<bool> deleteBook(String id) => remoteDatasource.deleteBook(id);
}
