import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthState { idle, loading, success, error }

/// ViewModel de autenticación con Provider.
class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthViewModel({required this.loginUseCase, required this.registerUseCase});

  AuthState _state = AuthState.idle;
  UserEntity? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login({required String email, required String password}) async {
    _setState(AuthState.loading);
    _clearError();
    try {
      _currentUser = await loginUseCase(email: email, password: password);
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _setState(AuthState.loading);
    _clearError();
    try {
      _currentUser = await registerUseCase(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _setState(AuthState.idle);
  }

  void _setState(AuthState s) { _state = s; notifyListeners(); }
  void _setError(String m) { _errorMessage = m; _state = AuthState.error; notifyListeners(); }
  void _clearError() => _errorMessage = null;
  void clearError() { _clearError(); notifyListeners(); }
}
