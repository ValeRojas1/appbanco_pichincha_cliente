import 'package:flutter/material.dart';
import '../services/ahorro_service.dart';
import '../model/cuenta_ahorro_model.dart';

class AhorroViewModel extends ChangeNotifier {
  final AhorroService _ahorroService = AhorroService();
  CuentaAhorroModel? _cuentaAhorro;
  bool _loading = false;

  CuentaAhorroModel? get cuentaAhorro => _cuentaAhorro;
  bool get loading => _loading;

  Future<void> cargarCuentaAhorro(String userid) async {
    _loading = true;
    notifyListeners();

    _cuentaAhorro = await _ahorroService.getCuentaAhorro(userid);

    _loading = false;
    notifyListeners();
  }
}
