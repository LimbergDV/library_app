import '../../domain/entities/book_entity.dart';

/// Modelo de datos para Libro.
/// Añade fromJson/toJson a la entidad de dominio.
class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.editorial,
    required super.numberOfPages,
    required super.urlImage,
    required super.backgroundColor,
  });

  /// Deserializa desde el JSON de la API.
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      editorial: json['editorial'] as String? ?? '',
      numberOfPages: (json['numberOfPages'] as num?)?.toInt() ?? 0,
      urlImage: json['urlImage'] as String? ?? '',
      backgroundColor: json['backgroundColor'] as String? ?? 'blue',
    );
  }

  /// Serializa los campos principales a JSON (sin imagen).
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'editorial': editorial,
    'numberOfPages': numberOfPages,
    'backgroundColor': backgroundColor,
  };

  /// Serializa solo los campos que se envían al crear/actualizar
  /// (sin id ni urlImage, que los gestiona el servidor).
  Map<String, dynamic> toRequestJson() => {
    'title': title,
    'author': author,
    'editorial': editorial,
    'numberOfPages': numberOfPages,
    'backgroundColor': backgroundColor,
  };
}
