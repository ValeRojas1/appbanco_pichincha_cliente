import 'package:flutter/material.dart';

// Estados posibles del login
enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthState _state = AuthState.idle;
  String _errorMessage = '';

  AuthState get state => _state;
  String get errorMessage => _errorMessage;

  // Credenciales hardcodeadas para S9
  static const String _dniValido = '12345678';
  static const String _passwordValida = 'pichincha123';

  Future<void> login(String dni, String password) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    // Simula una pequeña demora de red
    await Future.delayed(const Duration(milliseconds: 800));

    if (dni == _dniValido && password == _passwordValida) {
      _state = AuthState.success;
    } else {
      _state = AuthState.error;
      _errorMessage = 'DNI o contraseña incorrectos';
    }
    notifyListeners();
  }

  void reset() {
    _state = AuthState.idle;
    _errorMessage = '';
    notifyListeners();
  }
}