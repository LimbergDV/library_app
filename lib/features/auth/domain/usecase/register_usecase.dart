import 'package:equatable/equatable.dart';
import 'package:library_app/features/auth/domain/repositories/auth_repository.dart';
import '../entities/auth_entity.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<AuthEntity> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;

  const RegisterParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}