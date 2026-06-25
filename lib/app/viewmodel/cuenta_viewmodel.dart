import 'package:flutter/material.dart';
import '../services/cuenta_service.dart';
import '../model/cuenta_model.dart';
import '../model/transaccion_model.dart';

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

  Future<List<TransaccionModel>> cargarTransaccionesCuenta(String cuentaid) async {
    return await _cuentaService.getTransaccionesPorCuenta(cuentaid);
  }

  Future<String?> buscarDestinatario(String telefono) async {
    return await _cuentaService.buscarNombrePorTelefono(telefono);
  }

  Future<bool> realizarPagoYapePlin({
    required String userid,
    required String cuentaid,
    required double montoActual,
    required double montoDescontar,
    required String descripcion,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final nuevoSaldo = montoActual - montoDescontar;
    final okSaldo = await _cuentaService.actualizarSaldo(cuentaid, nuevoSaldo);
    if (!okSaldo) {
      _loading = false;
      _error = "Error al actualizar el saldo de la cuenta.";
      notifyListeners();
      return false;
    }

    final txnData = {
      'userid': userid,
      'cuentaid': cuentaid,
      'tipo': 'debito',
      'descripcion': descripcion,
      'monto': montoDescontar,
      'fecha': DateTime.now().toUtc().toIso8601String(),
    };

    final okTxn = await _cuentaService.registrarTransaccion(txnData);
    if (!okTxn) {
      // Intentamos revertir el saldo o al menos registrar el error
      _error = "Error al registrar la transacción en el historial.";
    }

    // Recargar cuentas locales
    _cuentas = await _cuentaService.getCuentas(userid);

    _loading = false;
    notifyListeners();
    return true;
  }
}
