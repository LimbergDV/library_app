import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/create_book_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../domain/usecases/get_book_usecase.dart';
import '../../domain/usecases/update_book_usecase.dart';

enum BooksStatus { idle, loading, success, error }

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

  BooksStatus _status = BooksStatus.idle;
  List<BookEntity> _books = [];
  String? _errorMessage;
  bool _isSubmitting = false;

  BooksStatus get status => _status;
  List<BookEntity> get books => List.unmodifiable(_books);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == BooksStatus.loading;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadBooks() async {
    debugPrint('[BooksVM] loadBooks() iniciado');
    _setStatus(BooksStatus.loading);
    _clearError();
    try {
      _books = await getBooksUseCase();
      debugPrint('[BooksVM] loadBooks() OK — ${_books.length} libros');
      _setStatus(BooksStatus.success);
    } catch (e) {
      debugPrint('[BooksVM] loadBooks() ERROR: $e');
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> createBook({
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) async {
    debugPrint('[BooksVM] createBook() iniciado — title: $title');
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
      debugPrint('[BooksVM] createBook() OK — id: ${newBook.id}');
      _books = [newBook, ..._books];
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[BooksVM] createBook() ERROR: $e');
      _isSubmitting = false;
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> updateBook({
    required String id,
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) async {
    debugPrint('[BooksVM] updateBook() iniciado — id: $id, title: $title');
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
      debugPrint('[BooksVM] updateBook() OK — id: ${updatedBook.id}');
      final index = _books.indexWhere((b) => b.id == id);
      if (index != -1) {
        _books = [..._books];
        _books[index] = updatedBook;
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[BooksVM] updateBook() ERROR: $e');
      _isSubmitting = false;
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> deleteBook(String id) async {
    debugPrint('[BooksVM] deleteBook() iniciado — id: $id');
    _isSubmitting = true;
    _clearError();
    notifyListeners();

    try {
      await deleteBookUseCase(id);
      debugPrint('[BooksVM] deleteBook() OK');
      _books = _books.where((b) => b.id != id).toList();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[BooksVM] deleteBook() ERROR: $e');
      _isSubmitting = false;
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  List<BookEntity> searchBooks(String query) {
    if (query.trim().isEmpty) return books;
    final q = query.toLowerCase();
    return _books.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.editorial.toLowerCase().contains(q);
    }).toList();
  }

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