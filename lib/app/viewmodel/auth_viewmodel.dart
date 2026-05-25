import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../model/usuario_model.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthState _state = AuthState.idle;
  String _errorMessage = '';
  UsuarioModel? _usuario;

  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  UsuarioModel? get usuario => _usuario;

  Future<void> login(String dni, String password) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _authService.login(dni, password);
      if (user != null) {
        _usuario = user;
        _state = AuthState.success;
      } else {
        _state = AuthState.error;
        _errorMessage = 'DNI o contraseña incorrectos';
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Error de conexión';
    }
    notifyListeners();
  }

  void reset() {
    _state = AuthState.idle;
    _errorMessage = '';
    notifyListeners();
  }

  void logout() {
    _usuario = null;
    _state = AuthState.idle;
    notifyListeners();
  }
}
