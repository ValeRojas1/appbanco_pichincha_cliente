import 'package:flutter/material.dart';
import '../model/usuario_model.dart';
import '../model/cuenta_model.dart';

class HomeViewModel extends ChangeNotifier {
  // Datos hardcodeados del cliente — S9
  final UsuarioModel usuario = UsuarioModel(
    nombre: 'Juan Carlos Pérez',
    dni: '12345678',
    email: 'juanperez@mibanco.com',
  );

  final CuentaModel cuentaAhorros = CuentaModel(
    numeroCuenta: '001-123456789-0-01',
    tipoCuenta: 'ahorros',
    saldo: 4850.75,
    moneda: 'S/',
  );

  final CuentaModel cuentaCredito = CuentaModel(
    numeroCuenta: '001-987654321-0-02',
    tipoCuenta: 'credito',
    saldo: 10000.00,
    moneda: 'S/',
    montoPendiente: 2340.50,
  );

  // Tab activo en el BottomNavBar
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  void cambiarTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  // Formato de moneda
  String formatearMonto(double monto) {
    return 'S/ ${monto.toStringAsFixed(2)}';
  }
}