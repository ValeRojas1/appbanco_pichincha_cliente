import '../core/estado_solicitud.dart';

/// Aviso generado al abrir la app cuando cambió el estado de una solicitud.
class NotificacionSolicitudLocal {
  final String solicitudId;
  final String titulo;
  final String mensaje;
  final String estado;
  final double monto;
  final DateTime detectadaEn;

  const NotificacionSolicitudLocal({
    required this.solicitudId,
    required this.titulo,
    required this.mensaje,
    required this.estado,
    required this.monto,
    required this.detectadaEn,
  });

  EstadoSolicitud get estadoEnum => EstadoSolicitud.fromString(estado);
}
