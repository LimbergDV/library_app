import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Iniciar sesión.
/// Encapsula la lógica de negocio de autenticación.
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase({required this.repository});

  /// Ejecuta el caso de uso con las credenciales proporcionadas.
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    // Validaciones de dominio
    if (email.trim().isEmpty) {
      throw Exception('El correo electrónico es requerido');
    }
    if (!_isValidEmail(email)) {
      throw Exception('El correo electrónico no es válido');
    }
    if (password.isEmpty) {
      throw Exception('La contraseña es requerida');
    }
    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    return repository.login(email: email.trim(), password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
