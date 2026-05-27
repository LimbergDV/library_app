import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Registrar nuevo usuario.
/// La API solo requiere email y password.
class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase({required this.repository});

  Future<UserEntity> call({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.trim().isEmpty) throw Exception('El correo electrónico es requerido');
    if (!_isValidEmail(email)) throw Exception('El correo electrónico no es válido');
    if (password.isEmpty) throw Exception('La contraseña es requerida');
    if (password.length < 6) throw Exception('La contraseña debe tener al menos 6 caracteres');
    if (password != confirmPassword) throw Exception('Las contraseñas no coinciden');

    return repository.register(email: email.trim(), password: password);
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
