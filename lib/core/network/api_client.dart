import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiClient {
  final http.Client _client;
  final String baseUrl;
  String? authToken;

  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (authToken != null && authToken!.isNotEmpty)
      'Authorization': 'Bearer $authToken',
  };

  Map<String, String> get _authHeader => {
    if (authToken != null && authToken!.isNotEmpty)
      'Authorization': 'Bearer $authToken',
  };

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('>>> GET $uri');
      final response = await _client
          .get(uri, headers: _jsonHeaders)
          .timeout(const Duration(seconds: 30));
      debugPrint('<<< ${response.statusCode} ${response.body}');
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Sin conexión a internet');
    } catch (e) {
      throw NetworkException('Error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('>>> POST $uri body: ${jsonEncode(body)}');
      final response = await _client
          .post(uri, headers: _jsonHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      debugPrint('<<< ${response.statusCode} ${response.body}');
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Sin conexión a internet');
    } catch (e) {
      throw NetworkException('Error: $e');
    }
  }

  /// Envía multipart/form-data.
  Future<Map<String, dynamic>> postMultipart(
      String endpoint, {
        Map<String, String> fields = const {},
        Map<String, String> jsonParts = const {},
        File? imageFile,
        String imageFieldName = 'image',
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('>>> POST multipart $uri fields: $fields jsonParts: $jsonParts hasImage: ${imageFile != null}');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_authHeader)
        ..fields.addAll(fields);

      // Agregamos las partes JSON especificando explícitamente el Content-Type application/json
      jsonParts.forEach((key, value) {
        request.files.add(
          http.MultipartFile.fromString(
            key,
            value,
            contentType: MediaType('application', 'json'),
          ),
        );
      });

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(imageFieldName, imageFile.path),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      debugPrint('<<< ${response.statusCode} ${response.body}');
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Sin conexión a internet');
    } catch (e) {
      throw NetworkException('Error: $e');
    }
  }

  Future<Map<String, dynamic>> putMultipart(
      String endpoint, {
        Map<String, String> fields = const {},
        Map<String, String> jsonParts = const {},
        File? imageFile,
        String imageFieldName = 'image',
      }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('>>> PUT multipart $uri fields: $fields jsonParts: $jsonParts hasImage: ${imageFile != null}');
      final request = http.MultipartRequest('PUT', uri)
        ..headers.addAll(_authHeader)
        ..fields.addAll(fields);

      // Agregamos las partes JSON especificando explícitamente el Content-Type application/json
      jsonParts.forEach((key, value) {
        request.files.add(
          http.MultipartFile.fromString(
            key,
            value,
            contentType: MediaType('application', 'json'),
          ),
        );
      });

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(imageFieldName, imageFile.path),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      debugPrint('<<< ${response.statusCode} ${response.body}');
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Sin conexión a internet');
    } catch (e) {
      throw NetworkException('Error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('>>> DELETE $uri');
      final response = await _client
          .delete(uri, headers: _jsonHeaders)
          .timeout(const Duration(seconds: 30));
      debugPrint('<<< ${response.statusCode} ${response.body}');
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Sin conexión a internet');
    } catch (e) {
      throw NetworkException('Error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (statusCode == 400) {
      throw ApiException('Solicitud inválida (400): ${response.body}');
    } else if (statusCode == 401) {
      throw ApiException('No autorizado (401)');
    } else if (statusCode == 403) {
      throw ApiException('Prohibido (403): token inválido o ausente');
    } else if (statusCode == 404) {
      throw ApiException('No encontrado (404): ${response.body}');
    } else if (statusCode == 500) {
      throw ApiException('Error del servidor (500): ${response.body}');
    } else {
      throw ApiException('HTTP $statusCode: ${response.body}');
    }
  }

  void dispose() => _client.close();
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}