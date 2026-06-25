import 'package:flutter/material.dart';
import '../model/credito_model.dart';
import '../model/pago_mensual_model.dart';
import '../services/credito_service.dart';
import '../core/amortizacion_francesa.dart';

class CreditoViewModel extends ChangeNotifier {
  final CreditoService _service = CreditoService();

  List<CreditoModel> _creditos = [];
  List<PagoMensualModel> _pagos = [];
  bool _loading = false;
  String? _error;

  // Simulador
  double _montoSim = 5000;
  int _plazoSim = 12;
  double _teaSim = 28.5;

  double get cuotaSimulada =>
      AmortizacionFrancesa.calcularCuota(_montoSim, _teaSim, _plazoSim);

  double get totalInteresesSim =>
      AmortizacionFrancesa.totalIntereses(_montoSim, _teaSim, _plazoSim);

  List<CreditoModel> get creditos => _creditos;
  List<CreditoModel> get creditosVigentes =>
      _creditos.where((c) => c.estaVigente || c.estaMoroso).toList();
  List<CreditoModel> get creditosHistorial =>
      _creditos.where((c) => !c.estaVigente && !c.estaMoroso).toList();
  List<PagoMensualModel> get pagos => _pagos;
  bool get loading => _loading;
  String? get error => _error;
  double get montoSim => _montoSim;
  int get plazoSim => _plazoSim;
  double get teaSim => _teaSim;

  Future<void> cargarCreditos(String clienteId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    _creditos = await _service.getCreditosCliente(clienteId);
    _pagos = await _service.getPagosMensuales(clienteId);
    _loading = false;
    notifyListeners();
  }

  void actualizarSimulador({double? monto, int? plazo, double? tea}) {
    if (monto != null) _montoSim = monto;
    if (plazo != null) _plazoSim = plazo;
    if (tea != null) _teaSim = tea;
    notifyListeners();
  }
}
