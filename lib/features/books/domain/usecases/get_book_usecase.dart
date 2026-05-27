import 'dart:io';
import '../entities/book_entity.dart';
import '../repositories/books_repository.dart';

/// Caso de uso: Obtener lista de libros (GET).
class GetBooksUseCase {
  final BooksRepository repository;
  const GetBooksUseCase({required this.repository});

  Future<List<BookEntity>> call() => repository.getBooks();
}