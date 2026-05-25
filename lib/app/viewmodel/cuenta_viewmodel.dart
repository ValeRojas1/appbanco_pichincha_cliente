import 'package:flutter/material.dart';
import '../services/cuenta_service.dart';
import '../model/cuenta_model.dart';

class CuentaViewModel extends ChangeNotifier {
  final CuentaService _cuentaService = CuentaService();
  List<CuentaModel> _cuentas = [];
  bool _loading = false;
  String? _error;

  List<CuentaModel> get cuentas => _cuentas;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> cargarCuentas(String userid) async {
    _loading = true;
    _error = null;
    notifyListeners();

    _cuentas = await _cuentaService.getCuentas(userid);

    _loading = false;
    notifyListeners();
  }
}
