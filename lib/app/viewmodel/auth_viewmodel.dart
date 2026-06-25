import 'package:flutter/material.dart';
import '../model/cliente_model.dart';
import '../services/auth_service.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _service = AuthService();
  AuthState _state = AuthState.idle;
  ClienteModel? _cliente;
  String? _errorMessage;

  AuthState get state => _state;
  ClienteModel? get cliente => _cliente;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> login(String dni, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    final result = await _service.login(dni, password);
    if (result != null) {
      _cliente = result;
      _state = AuthState.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          'Los datos ingresados no coinciden. Revisa tu DNI y contraseña e inténtalo de nuevo.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrar({
    required String correo,
    required String dni,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _service.registrar(
      correo: correo,
      dni: dni,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      password: password,
    );

    if (result.success) {
      if (result.requiereConfirmacion) {
        _successMessage =
            'Cuenta creada. Revisa tu correo para confirmar el registro y luego inicia sesión con tu DNI.';
        _state = AuthState.idle;
      } else {
        _cliente = result.cliente;
        _state = AuthState.success;
        _successMessage = '¡Bienvenido/a, ${result.cliente!.primerNombre}!';
      }
      notifyListeners();
      return !result.requiereConfirmacion;
    }

    _errorMessage = result.errorMessage ??
        'No pudimos completar el registro. Inténtalo de nuevo.';
    _state = AuthState.error;
    notifyListeners();
    return false;
  }

  Future<bool> recuperarSesion() async {
    final result = await _service.recuperarSesion();
    if (result != null) {
      _cliente = result;
      _state = AuthState.success;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _service.logout();
    _cliente = null;
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _state = AuthState.idle;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
