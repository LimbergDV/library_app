import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/create_book_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../domain/usecases/get_book_usecase.dart';
import '../../domain/usecases/update_book_usecase.dart';


/// Estados del ViewModel de libros.
enum BooksStatus { idle, loading, success, error }

/// ViewModel del CRUD de libros.
/// Gestiona el estado reactivo con Provider (ChangeNotifier).
/// Desacopla completamente la vista de la lógica de negocio.
class BooksViewModel extends ChangeNotifier {
  final GetBooksUseCase getBooksUseCase;
  final CreateBookUseCase createBookUseCase;
  final UpdateBookUseCase updateBookUseCase;
  final DeleteBookUseCase deleteBookUseCase;

  BooksViewModel({
    required this.getBooksUseCase,
    required this.createBookUseCase,
    required this.updateBookUseCase,
    required this.deleteBookUseCase,
  });

  // ─── Estado reactivo ──────────────────────────────────────
  BooksStatus _status = BooksStatus.idle;
  List<BookEntity> _books = [];
  String? _errorMessage;
  bool _isSubmitting = false;

  // ─── Getters públicos ─────────────────────────────────────
  BooksStatus get status => _status;
  List<BookEntity> get books => List.unmodifiable(_books);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == BooksStatus.loading;
  bool get isSubmitting => _isSubmitting;

  // ─────────────────────────────────────────────────────────
  // GET - Cargar libros
  // ─────────────────────────────────────────────────────────
  Future<void> loadBooks() async {
    _setStatus(BooksStatus.loading);
    _clearError();

    try {
      _books = await getBooksUseCase();
      _setStatus(BooksStatus.success);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────────────────
  // POST - Crear libro
  // ─────────────────────────────────────────────────────────
  Future<bool> createBook({
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) async {
    _isSubmitting = true;
    _clearError();
    notifyListeners();

    try {
      final newBook = await createBookUseCase(
        title: title,
        author: author,
        editorial: editorial,
        numberOfPages: numberOfPages,
        backgroundColor: backgroundColor,
        imageFile: imageFile,
      );
      // Actualización optimista: agregar al inicio de la lista
      _books = [newBook, ..._books];
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // PUT - Actualizar libro
  // ─────────────────────────────────────────────────────────
  Future<bool> updateBook({
    required String id,
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) async {
    _isSubmitting = true;
    _clearError();
    notifyListeners();

    try {
      final updatedBook = await updateBookUseCase(
        id: id,
        title: title,
        author: author,
        editorial: editorial,
        numberOfPages: numberOfPages,
        backgroundColor: backgroundColor,
        imageFile: imageFile,
      );
      // Actualizar en la lista local
      final index = _books.indexWhere((b) => b.id == id);
      if (index != -1) {
        _books = [..._books];
        _books[index] = updatedBook;
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // DELETE - Eliminar libro
  // ─────────────────────────────────────────────────────────
  Future<bool> deleteBook(String id) async {
    _isSubmitting = true;
    _clearError();
    notifyListeners();

    try {
      await deleteBookUseCase(id);
      // Remover de la lista local
      _books = _books.where((b) => b.id != id).toList();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // ─── Búsqueda local ───────────────────────────────────────
  List<BookEntity> searchBooks(String query) {
    if (query.trim().isEmpty) return books;
    final q = query.toLowerCase();
    return _books.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.editorial.toLowerCase().contains(q);
    }).toList();
  }

  // ─── Helpers privados ─────────────────────────────────────
  void _setStatus(BooksStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = BooksStatus.error;
    notifyListeners();
  }

  void _clearError() => _errorMessage = null;

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
