import 'dart:convert';
import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../models/book_model.dart';

class BooksRemoteDatasource {
  final ApiClient apiClient;

  const BooksRemoteDatasource({required this.apiClient});

  Future<List<BookModel>> getBooks() async {
    final response = await apiClient.get('/books');
    final success = response['success'] as bool? ?? false;
    if (!success) throw Exception(response['message'] ?? 'Error al obtener libros');
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((item) => BookModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<BookModel> createBook({
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) async {
    final bookJson = jsonEncode({
      'title': title,
      'author': author,
      'editorial': editorial,
      'numberOfPages': numberOfPages,
      'backgroundColor': backgroundColor,
    });

    final response = await apiClient.postMultipart(
      '/books',
      jsonParts: {'book': bookJson},
      imageFile: imageFile,
      imageFieldName: 'image',
    );

    final success = response['success'] as bool? ?? false;
    if (!success) throw Exception(response['message'] ?? 'Error al crear libro');
    return BookModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<BookModel> updateBook({
    required String id,
    required String title,
    required String author,
    required String editorial,
    required int numberOfPages,
    required String backgroundColor,
    File? imageFile,
  }) async {
    final bookJson = jsonEncode({
      'id': id,
      'title': title,
      'author': author,
      'editorial': editorial,
      'numberOfPages': numberOfPages,
      'backgroundColor': backgroundColor,
    });

    final response = await apiClient.putMultipart(
      '/books',
      jsonParts: {'book': bookJson},
      imageFile: imageFile,
      imageFieldName: 'image',
    );

    final success = response['success'] as bool? ?? false;
    if (!success) throw Exception(response['message'] ?? 'Error al actualizar libro');
    return BookModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<bool> deleteBook(String id) async {
    final response = await apiClient.delete('/books/$id');
    final success = response['success'] as bool? ?? false;
    if (!success) throw Exception(response['message'] ?? 'Error al eliminar libro');
    return response['data'] as bool? ?? true;
  }
}