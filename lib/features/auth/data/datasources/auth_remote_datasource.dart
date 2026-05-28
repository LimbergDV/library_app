import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient apiClient;

  UserModel? _currentUser;

  AuthRemoteDatasource({required this.apiClient});

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Credenciales incorrectas');
    }

    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String? ?? '';

    apiClient.authToken = token;

    final user = UserModel.fromLoginJson(token: token, email: email);
    _currentUser = user;
    return user;
  }

  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post('/users', {
      'email': email,
      'password': password,
    });

    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Error al registrar usuario');
    }

    final data = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromRegisterJson(data);
    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    apiClient.authToken = null;
    _currentUser = null;
  }

  UserModel? getCurrentUser() => _currentUser;
}