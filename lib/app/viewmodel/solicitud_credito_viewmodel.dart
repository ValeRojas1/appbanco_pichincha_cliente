import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/solicitud_credito_model.dart';
import '../model/solicitud_documento_model.dart';
import '../services/solicitud_credito_service.dart';
import '../services/solicitud_documento_service.dart';

class SolicitudCreditoViewModel extends ChangeNotifier {
  final SolicitudCreditoService _service = SolicitudCreditoService();
  final SolicitudDocumentoService _docService = SolicitudDocumentoService();

  List<SolicitudCreditoModel> _solicitudes = [];
  List<SolicitudDocumentoModel> _documentos = [];
  SolicitudCreditoModel? _seleccionada;
  bool _loading = false;
  RealtimeChannel? _canal;

  List<SolicitudCreditoModel> get solicitudes => _solicitudes;
  List<SolicitudDocumentoModel> get documentos => _documentos;
  SolicitudCreditoModel? get seleccionada => _seleccionada;
  bool get loading => _loading;

  Future<void> cargarSolicitudes(String dni) async {
    _loading = true;
    notifyListeners();
    _solicitudes = await _service.getSolicitudes(dni);
    _loading = false;
    notifyListeners();
    cancelarSuscripcion();
    _canal = _service.suscribirCambios(dni, _onCambioSolicitud);
  }

  Future<void> recargar(String dni) => cargarSolicitudes(dni);

  void _onCambioSolicitud(SolicitudCreditoModel actualizada) {
    final idx = _solicitudes.indexWhere((s) => s.id == actualizada.id);
    if (idx >= 0) {
      _solicitudes[idx] = actualizada;
    } else {
      _solicitudes.insert(0, actualizada);
    }
    if (_seleccionada?.id == actualizada.id) _seleccionada = actualizada;
    notifyListeners();
  }

  Future<void> seleccionarSolicitud(SolicitudCreditoModel solicitud) async {
    _seleccionada = solicitud;
    _documentos = await _docService.getDocumentos(solicitud.id);
    notifyListeners();
  }

  void cancelarSuscripcion() {
    if (_canal != null) {
      _service.cancelarSuscripcion(_canal!);
      _canal = null;
    }
  }

  @override
  void dispose() {
    cancelarSuscripcion();
    super.dispose();
  }
}
