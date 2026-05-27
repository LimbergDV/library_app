import 'package:library_app/core/network/result.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login({
   required String email,
   required String password
});

  Future<AuthEntity> register({
   required String email,
   required String password
});

}