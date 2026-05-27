import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación concreta del repositorio de autenticación.
/// Ahora delega al datasource remoto (API real).
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  const AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    return remoteDatasource.login(email: email, password: password);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
  }) async {
    return remoteDatasource.register(email: email, password: password);
  }

  @override
  Future<void> logout() => remoteDatasource.logout();

  @override
  UserEntity? getCurrentUser() => remoteDatasource.getCurrentUser();
}
