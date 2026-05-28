import 'dart:io';
import '../entities/book_entity.dart';
import '../repositories/books_repository.dart';

class CreateBookUseCase {
  final BooksRepository repository;
  const CreateBookUseCase({required this.repository});

  Future<BookEntity> call({
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) {
    if (title.trim().isEmpty) throw Exception('El título es requerido');
    if (author.trim().isEmpty) throw Exception('El autor es requerido');
    if (editorial.trim().isEmpty) throw Exception('La editorial es requerida');
    if (numberOfPages <= 0) {
      throw Exception('El número de páginas debe ser mayor a 0');
    }

    return repository.createBook(
      title: title.trim(),
      author: author.trim(),
      editorial: editorial.trim(),
      numberOfPages: numberOfPages,
      backgroundColor: backgroundColor,
      imageFile: imageFile,
    );
  }
}