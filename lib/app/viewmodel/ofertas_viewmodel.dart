import 'package:flutter/material.dart';
import '../model/credito_preaprobado_model.dart';
import '../model/campana_activa_model.dart';
import '../model/alerta_cartera_model.dart';
import '../services/ofertas_service.dart';

class OfertasViewModel extends ChangeNotifier {
  final OfertasService _service = OfertasService();

  CreditoPreaprobadoModel? _preaprobado;
  List<CampanaActivaModel> _campanas = [];
  List<AlertaCarteraModel> _alertas = [];
  bool _loading = false;

  CreditoPreaprobadoModel? get preaprobado => _preaprobado;
  List<CampanaActivaModel> get campanas => _campanas;
  List<AlertaCarteraModel> get alertas => _alertas;
  List<AlertaCarteraModel> get alertasNoLeidas =>
      _alertas.where((a) => !a.leida).toList();
  bool get loading => _loading;
  bool get tienePreaprobado => _preaprobado != null;

  Future<void> cargar(String clienteId) async {
    _loading = true;
    notifyListeners();
    _preaprobado = await _service.getPreaprobado(clienteId);
    _campanas = await _service.getCampanas(clienteId);
    _alertas = await _service.getAlertas(clienteId);
    _loading = false;
    notifyListeners();
  }

  Future<void> marcarAlertaLeida(String alertaId) async {
    await _service.marcarAlertaLeida(alertaId);
    final idx = _alertas.indexWhere((a) => a.id == alertaId);
    if (idx >= 0) {
      _alertas[idx] = AlertaCarteraModel(
        id: _alertas[idx].id,
        clienteId: _alertas[idx].clienteId,
        titulo: _alertas[idx].titulo,
        mensaje: _alertas[idx].mensaje,
        severidad: _alertas[idx].severidad,
        leida: true,
        createdat: _alertas[idx].createdat,
      );
      notifyListeners();
    }
  }
}
