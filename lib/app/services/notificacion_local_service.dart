import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/estado_solicitud.dart';
import '../model/notificacion_solicitud_local.dart';
import '../model/solicitud_credito_model.dart';

class _Snapshot {
  final String estado;
  final String? fechaDesembolsoIso;

  const _Snapshot({required this.estado, this.fechaDesembolsoIso});

  Map<String, dynamic> toJson() => {
        'estado': estado,
        'fechaDesembolsoIso': fechaDesembolsoIso,
      };

  factory _Snapshot.fromJson(Map<String, dynamic> json) => _Snapshot(
        estado: json['estado']?.toString() ?? '',
        fechaDesembolsoIso: json['fechaDesembolsoIso']?.toString(),
      );

  factory _Snapshot.fromSolicitud(SolicitudCreditoModel s) => _Snapshot(
        estado: s.estado,
        fechaDesembolsoIso: s.fechaDesembolso?.toIso8601String(),
      );
}

class NotificacionLocalService {
  static const _estadosNotificables = {
    'aprobada',
    'rechazada',
    'condicionada',
    'desembolsada',
  };

  String _storageKey(String dni) => 'solicitud_baseline_$dni';

  Future<Map<String, _Snapshot>> _cargarBaseline(String dni) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(dni));
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) => MapEntry(k, _Snapshot.fromJson(Map<String, dynamic>.from(v as Map))),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _guardarBaseline(String dni, Map<String, _Snapshot> baseline) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      baseline.map((k, v) => MapEntry(k, v.toJson())),
    );
    await prefs.setString(_storageKey(dni), encoded);
  }

  Future<void> limpiarBaseline(String dni) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(dni));
  }

  /// Compara solicitudes actuales con lo último visto. La primera vez no avisa
  /// (solo guarda referencia). Las siguientes veces avisa cambios importantes.
  Future<List<NotificacionSolicitudLocal>> detectarNovedades(
    String dni,
    List<SolicitudCreditoModel> solicitudes,
  ) async {
    final baseline = await _cargarBaseline(dni);
    final novedades = <NotificacionSolicitudLocal>[];
    var baselineActualizado = false;

    for (final s in solicitudes) {
      final prev = baseline[s.id];
      final actual = _Snapshot.fromSolicitud(s);

      if (prev == null) {
        baseline[s.id] = actual;
        baselineActualizado = true;
        continue;
      }

      if (_hayNovedad(s, prev)) {
        novedades.add(_crearNotificacion(s, prev));
      }
    }

    if (baselineActualizado) {
      await _guardarBaseline(dni, baseline);
    }

    return novedades;
  }

  /// Marca el estado actual como visto (tras mostrar el aviso al usuario).
  Future<void> guardarBaseline(
    String dni,
    List<SolicitudCreditoModel> solicitudes,
  ) async {
    final baseline = {
      for (final s in solicitudes) s.id: _Snapshot.fromSolicitud(s),
    };
    await _guardarBaseline(dni, baseline);
  }

  bool _hayNovedad(SolicitudCreditoModel s, _Snapshot prev) {
    if (prev.estado != s.estado && _estadosNotificables.contains(s.estado)) {
      return true;
    }

    final fechaActual = s.fechaDesembolso?.toIso8601String();
    if ((s.estado == 'aprobada' || s.estado == 'condicionada') &&
        fechaActual != null &&
        fechaActual != prev.fechaDesembolsoIso) {
      return true;
    }

    return false;
  }

  NotificacionSolicitudLocal _crearNotificacion(
    SolicitudCreditoModel s,
    _Snapshot prev,
  ) {
    final estado = s.estadoEnum;
    var titulo = 'Actualización de tu solicitud';

    final soloFecha = prev.estado == s.estado &&
        (s.estado == 'aprobada' || s.estado == 'condicionada') &&
        s.fechaDesembolso != null &&
        s.fechaDesembolso!.toIso8601String() != prev.fechaDesembolsoIso;

    if (soloFecha) {
      titulo = 'Fecha de desembolso confirmada';
    } else {
      switch (estado) {
        case EstadoSolicitud.aprobada:
          titulo = '¡Tu crédito fue aprobado!';
          break;
        case EstadoSolicitud.rechazada:
          titulo = 'Resultado de tu solicitud';
          break;
        case EstadoSolicitud.condicionada:
          titulo = 'Tu solicitud está condicionada';
          break;
        case EstadoSolicitud.desembolsada:
          titulo = 'Crédito desembolsado';
          break;
        default:
          break;
      }
    }

    var mensaje = s.mensajeEstado;
    if (s.motivoRechazo != null && s.motivoRechazo!.isNotEmpty) {
      mensaje = '$mensaje Motivo: ${s.motivoRechazo}.';
    }

    return NotificacionSolicitudLocal(
      solicitudId: s.id,
      titulo: titulo,
      mensaje: mensaje,
      estado: s.estado,
      monto: s.monto,
      detectadaEn: DateTime.now(),
    );
  }
}
