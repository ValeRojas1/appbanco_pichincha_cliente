import 'package:flutter/material.dart';
import '../model/notificacion_solicitud_local.dart';
import '../services/notificacion_local_service.dart';
import '../services/solicitud_credito_service.dart';

class NotificacionSolicitudViewModel extends ChangeNotifier {
  final NotificacionLocalService _service = NotificacionLocalService();
  final SolicitudCreditoService _solicitudService = SolicitudCreditoService();

  List<NotificacionSolicitudLocal> _pendientes = [];
  bool _revisando = false;

  List<NotificacionSolicitudLocal> get pendientes => _pendientes;
  int get cantidadPendientes => _pendientes.length;
  bool get revisando => _revisando;

  Future<void> revisarAlEntrar(String dni) async {
    _revisando = true;
    notifyListeners();
    try {
      final solicitudes = await _solicitudService.getSolicitudes(dni);
      _pendientes = await _service.detectarNovedades(dni, solicitudes);
    } finally {
      _revisando = false;
      notifyListeners();
    }
  }

  Future<void> marcarComoVistas(String dni) async {
    final solicitudes = await _solicitudService.getSolicitudes(dni);
    await _service.guardarBaseline(dni, solicitudes);
    _pendientes = [];
    notifyListeners();
  }

  Future<void> limpiarAlCerrarSesion(String dni) async {
    await _service.limpiarBaseline(dni);
    _pendientes = [];
    notifyListeners();
  }
}
