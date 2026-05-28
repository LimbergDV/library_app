/// Entidad de dominio para Libro.
/// Pura, sin dependencias de Flutter ni de frameworks externos.
class BookEntity {
  final String id;
  final String title;
  final String author;
  final String editorial;
  final int numberOfPages;
  final String urlImage;
  final String backgroundColor;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.editorial,
    required this.numberOfPages,
    required this.urlImage,
    required this.backgroundColor,
  });

  int get backgroundColorValue {
    final colorMap = {
      'red': 0xFFE53E3E,
      'blue': 0xFF4A6CF7,
      'green': 0xFF38A169,
      'yellow': 0xFFD69E2E,
      'purple': 0xFF805AD5,
      'pink': 0xFFED64A6,
      'orange': 0xFFDD6B20,
      'teal': 0xFF319795,
      'cyan': 0xFF0BC5EA,
      'gray': 0xFF718096,
      'grey': 0xFF718096,
      'black': 0xFF1A202C,
      'white': 0xFFFFFFFF,
    };

    final lower = backgroundColor.toLowerCase().trim();
    if (colorMap.containsKey(lower)) return colorMap[lower]!;

    try {
      final hex = lower.replaceAll('#', '');
      if (hex.length == 6) return int.parse('FF$hex', radix: 16);
      if (hex.length == 8) return int.parse(hex, radix: 16);
    } catch (_) {}

    return 0xFF4A6CF7;
  }
}
