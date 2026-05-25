import 'package:flutter/material.dart';
import '../services/prestamo_service.dart';
import '../model/solicitud_prestamo_model.dart';

class PrestamoViewModel extends ChangeNotifier {
  final PrestamoService _prestamoService = PrestamoService();
  List<SolicitudPrestamoModel> _solicitudes = [];
  bool _loading = false;
  String? _error;

  List<SolicitudPrestamoModel> get solicitudes => _solicitudes;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> cargarSolicitudes(String userid) async {
    _loading = true;
    _error = null;
    notifyListeners();

    _solicitudes = await _prestamoService.getSolicitudes(userid);

    _loading = false;
    notifyListeners();
  }

  Future<bool> crearSolicitud(Map<String, dynamic> data) async {
    final result = await _prestamoService.crearSolicitud(data);
    return result != null;
  }
}
