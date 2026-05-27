import '../repositories/books_repository.dart';

/// Caso de uso: Eliminar libro (DELETE).
class DeleteBookUseCase {
  final BooksRepository repository;
  const DeleteBookUseCase({required this.repository});

  Future<bool> call(String id) {
    if (id.isEmpty) throw Exception('ID inválido');
    return repository.deleteBook(id);
  }
}