/// Constantes de red centralizadas
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://api.aleosh.online';

  // ── Endpoints ─────────────────────────────────────────────────
  static const String books = '/books';
  static String bookById(String id) => '/books/$id';
}