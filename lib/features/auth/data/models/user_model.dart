import '../../domain/entities/user_entity.dart';

/// Modelo de datos para Usuario.
/// Extiende la entidad de dominio y añade lógica de serialización.
class UserModel extends UserEntity {
  final String token; // Token JWT retornado por /auth/login

  const UserModel({
    required super.id,
    required super.email,
    this.token = '',
  });

  /// Construye desde la respuesta de POST /users (registro)
  factory UserModel.fromRegisterJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  /// Construye desde la respuesta de POST /auth/login
  /// El login solo retorna el token; el id/email se pasa por separado
  factory UserModel.fromLoginJson({
    required String token,
    required String email,
  }) {
    return UserModel(
      id: '',
      email: email,
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
  };
}
