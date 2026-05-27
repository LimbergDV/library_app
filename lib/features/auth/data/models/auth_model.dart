import 'package:library_app/features/auth/domain/entities/auth_entity.dart';

/// Modelo de datos del usuario.
/// Mapea el JSON de la API a la entidad de dominio.
class UserModel {
  final String id;
  final String username;
  final String email;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    username: json['username']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
  );

  AuthEntity toEntity() => AuthEntity(
    id: id,
    username: username,
    email: email,
  );
}