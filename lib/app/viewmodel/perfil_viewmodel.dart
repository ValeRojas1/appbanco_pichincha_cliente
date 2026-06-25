import 'package:flutter/material.dart';
import '../model/cliente_model.dart';
import '../services/perfil_service.dart';

class PerfilViewModel extends ChangeNotifier {
  final PerfilService _service = PerfilService();

  ClienteModel? _cliente;
  Map<String, dynamic>? _posicion;
  bool _loading = false;

  ClienteModel? get cliente => _cliente;
  Map<String, dynamic>? get posicion => _posicion;
  bool get loading => _loading;

  Future<void> cargar(ClienteModel clienteInicial) async {
    _cliente = clienteInicial;
    _loading = true;
    notifyListeners();
    // Refrescar desde DB
    final perfil = await _service.getPerfil(clienteInicial.id);
    if (perfil != null) _cliente = perfil;
    // Posición financiera via Edge Function
    _posicion = await _service.getPosicionFinanciera(clienteInicial.documento);
    _loading = false;
    notifyListeners();
  }

  String get colorSemaforo {
    switch (_cliente?.clasificacionSbs) {
      case 'Normal':
        return 'verde';
      case 'CPP':
        return 'amarillo';
      case 'Deficiente':
        return 'naranja';
      case 'Dudoso':
        return 'rojo';
      case 'Pérdida':
        return 'negro';
      default:
        return 'gris';
    }
  }
}
