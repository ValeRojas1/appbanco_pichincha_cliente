import 'package:flutter/material.dart';
import '../services/cuenta_service.dart';
import '../services/ahorro_service.dart';
import '../model/usuario_model.dart';
import '../model/cuenta_model.dart';
import '../model/cuenta_ahorro_model.dart';

class HomeViewModel extends ChangeNotifier {
  final CuentaService _cuentaService = CuentaService();
  final AhorroService _ahorroService = AhorroService();

  UsuarioModel? _usuario;
  List<CuentaModel> _cuentasList = [];
  CuentaAhorroModel? _ahorro;
  int _tabIndex = 0;
  bool _loading = true;

  UsuarioModel? get usuario => _usuario;
  List<CuentaModel> get cuentasList => _cuentasList;
  CuentaModel? get cuentaCorriente => _cuentasList.cast<CuentaModel?>().firstWhere(
    (c) => c?.tipocuenta == 'corriente', orElse: () => null);
  CuentaModel? get cuentaAhorro => _cuentasList.cast<CuentaModel?>().firstWhere(
    (c) => c?.tipocuenta == 'ahorro', orElse: () => null);
  CuentaAhorroModel? get ahorro => _ahorro;
  int get tabIndex => _tabIndex;
  bool get loading => _loading;

  void init(UsuarioModel user) {
    _usuario = user;
    _cargarDatos();
  }

  Future<void> recargar() async {
    await _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    _loading = true;
    notifyListeners();

    _cuentasList = await _cuentaService.getCuentas(_usuario!.userid);
    _ahorro = await _ahorroService.getCuentaAhorro(_usuario!.userid);

    _loading = false;
    notifyListeners();
  }

  void cambiarTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  String formatearMonto(double monto, {String moneda = 'S/'}) {
    return '$moneda ${monto.toStringAsFixed(2)}';
  }

  void logout() {
    _usuario = null;
    _cuentasList = [];
    _ahorro = null;
    notifyListeners();
  }
}
