import '../../domain/entities/user_entity.dart';


class UserModel extends UserEntity {
  final String token;

  const UserModel({
    required super.id,
    required super.email,
    this.token = '',
  });

  factory UserModel.fromRegisterJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

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
