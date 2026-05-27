

import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{
  final String id;
  final String username;
  final String email;

  const AuthEntity ({
    required this.id,
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [id, username, email];
}