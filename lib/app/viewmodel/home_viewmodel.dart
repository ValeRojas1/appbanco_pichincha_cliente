import 'package:flutter/material.dart';
import '../model/cliente_model.dart';
import '../model/cuenta_model.dart';
import '../model/cuenta_ahorro_model.dart';
import '../services/cuenta_service.dart';
import '../services/ahorro_service.dart';
import '../services/auth_service.dart';

class HomeViewModel extends ChangeNotifier {
  final CuentaService _cuentaService = CuentaService();
  final AhorroService _ahorroService = AhorroService();
  final AuthService _authService = AuthService();

  ClienteModel? _cliente;
  List<CuentaModel> _cuentas = [];
  CuentaAhorroModel? _cuentaAhorro;
  bool _loading = false;
  int _tabIndex = 0;

  ClienteModel? get cliente => _cliente;
  List<CuentaModel> get cuentas => _cuentas;
  CuentaAhorroModel? get cuentaAhorro => _cuentaAhorro;
  bool get loading => _loading;
  int get tabIndex => _tabIndex;

  CuentaModel? get cuentaCorriente =>
      _cuentas.where((c) => c.tipocuenta.toLowerCase().contains('corriente')).firstOrNull;

  CuentaModel? get cuentaAhorrosCuenta =>
      _cuentas.where((c) => c.tipocuenta.toLowerCase().contains('ahorro')).firstOrNull;

  void init(ClienteModel cliente) {
    _cliente = cliente;
    recargar();
  }

  // Keep backward compat - accept dynamic to avoid breaking existing calls
  void initLegacy(dynamic usuario) {
    // no-op for legacy UsuarioModel, use init(ClienteModel) instead
  }

  Future<void> recargar() async {
    if (_cliente == null) return;
    _loading = true;
    notifyListeners();
    try {
      _cuentas = await _cuentaService.getCuentas(_cliente!.id);
      _cuentaAhorro = await _ahorroService.getCuentaAhorro(_cliente!.id);
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  void cambiarTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  String formatearMonto(double? monto) {
    if (monto == null) return 'S/ 0.00';
    return 'S/ ${monto.toStringAsFixed(2)}';
  }

  void logout() {
    _authService.logout();
    _cliente = null;
    _cuentas = [];
    _cuentaAhorro = null;
    _tabIndex = 0;
    notifyListeners();
  }
}
