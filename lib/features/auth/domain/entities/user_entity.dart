/// Entidad de dominio para el usuario autenticado.
/// La API solo retorna id y email, sin nombre.
class UserEntity {
  final String id;
  final String email;

  const UserEntity({
    required this.id,
    required this.email,
  });
}
