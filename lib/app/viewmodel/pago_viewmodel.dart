import 'package:flutter/material.dart';
import '../services/pago_service.dart';
import '../model/pago_model.dart';

class PagoViewModel extends ChangeNotifier {
  final PagoService _pagoService = PagoService();
  List<PagoModel> _pagos = [];
  bool _loading = false;
  String? _error;

  List<PagoModel> get pagos => _pagos;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> cargarPagos(String userid) async {
    _loading = true;
    _error = null;
    notifyListeners();

    _pagos = await _pagoService.getPagos(userid);

    _loading = false;
    notifyListeners();
  }

  Future<bool> registrarPago(Map<String, dynamic> data) async {
    final result = await _pagoService.registrarPago(data);
    return result != null;
  }
}
