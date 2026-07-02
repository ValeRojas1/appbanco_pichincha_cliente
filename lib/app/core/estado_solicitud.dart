import 'package:flutter/material.dart';
import 'package:appbanco_pichincha_cliente/app/ui/theme/app_theme.dart';

enum EstadoSolicitud {
  pendienteOperador,
  enAtencion,
  enviada,
  enRevision,
  pendiente,
  documentosPendientes,
  completa,
  enComite,
  condicionada,
  aprobada,
  rechazada,
  desembolsada;

  static EstadoSolicitud fromString(String s) {
    switch (s.toLowerCase()) {
      case 'pendiente_operador':
        return EstadoSolicitud.pendienteOperador;
      case 'pendiente':
        return EstadoSolicitud.pendiente;
      case 'en_atencion':
        return EstadoSolicitud.enAtencion;
      case 'enviada':
        return EstadoSolicitud.enviada;
      case 'en_revision':
      case 'en revision':
        return EstadoSolicitud.enRevision;
      case 'documentos_pendientes':
      case 'documentos pendientes':
        return EstadoSolicitud.documentosPendientes;
      case 'completa':
        return EstadoSolicitud.completa;
      case 'en_comite':
      case 'comite':
        return EstadoSolicitud.enComite;
      case 'aprobada':
        return EstadoSolicitud.aprobada;
      case 'condicionada':
        return EstadoSolicitud.condicionada;
      case 'rechazada':
        return EstadoSolicitud.rechazada;
      case 'desembolsada':
        return EstadoSolicitud.desembolsada;
      default:
        return EstadoSolicitud.enviada;
    }
  }

  String get label {
    switch (this) {
      case EstadoSolicitud.pendienteOperador:
        return 'Esperando asignación';
      case EstadoSolicitud.enAtencion:
        return 'Operador asignado';
      case EstadoSolicitud.enviada:
        return 'Enviada';
      case EstadoSolicitud.enRevision:
        return 'En Revisión';
      case EstadoSolicitud.pendiente:
        return 'Pendiente';
      case EstadoSolicitud.documentosPendientes:
        return 'Documentos pendientes';
      case EstadoSolicitud.completa:
        return 'Lista para transmitir';
      case EstadoSolicitud.enComite:
        return 'En Comité';
      case EstadoSolicitud.aprobada:
        return 'Aprobada';
      case EstadoSolicitud.condicionada:
        return 'Condicionada';
      case EstadoSolicitud.rechazada:
        return 'Rechazada';
      case EstadoSolicitud.desembolsada:
        return 'Desembolsada';
    }
  }

  /// Mensaje orientativo para el cliente según el avance de su solicitud.
  String get mensajeCliente => mensajeParaCliente();

  String mensajeParaCliente({DateTime? fechaDesembolso}) {
    switch (this) {
      case EstadoSolicitud.pendienteOperador:
      case EstadoSolicitud.pendiente:
        return 'Tu solicitud está en la bandeja de operadores. Un asesor te visitará pronto.';
      case EstadoSolicitud.enAtencion:
        return 'Un operador ya está atendiendo tu solicitud y coordinará la visita contigo.';
      case EstadoSolicitud.documentosPendientes:
        return 'Faltan documentos por completar. Sube los pendientes para avanzar.';
      case EstadoSolicitud.completa:
        return 'Tu expediente está completo. El operador lo transmitirá al banco.';
      case EstadoSolicitud.enviada:
        return 'Tu solicitud fue enviada y está en evaluación del banco.';
      case EstadoSolicitud.enRevision:
        return 'Estamos revisando la información de tu solicitud.';
      case EstadoSolicitud.enComite:
        return 'Tu crédito está en comité de aprobación.';
      case EstadoSolicitud.aprobada:
        if (fechaDesembolso != null) {
          return '¡Felicitaciones! Tu crédito fue aprobado. '
              'Fecha de desembolso: ${_formatearFecha(fechaDesembolso)}.';
        }
        return '¡Felicitaciones! Tu crédito fue aprobado. '
            'Te informaremos la fecha de desembolso pronto.';
      case EstadoSolicitud.condicionada:
        if (fechaDesembolso != null) {
          return 'Tu solicitud requiere condiciones adicionales. '
              'Fecha de desembolso estimada: ${_formatearFecha(fechaDesembolso)}.';
        }
        return 'Tu solicitud requiere algunas condiciones adicionales. '
            'Nos pondremos en contacto contigo.';
      case EstadoSolicitud.rechazada:
        return 'Tu solicitud no fue aprobada en esta ocasión.';
      case EstadoSolicitud.desembolsada:
        if (fechaDesembolso != null) {
          return 'El crédito fue desembolsado el ${_formatearFecha(fechaDesembolso)}. '
              'Revisa tus créditos activos.';
        }
        return 'El crédito fue desembolsado. Revisa tus créditos activos.';
    }
  }

  static String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  Color get color {
    switch (this) {
      case EstadoSolicitud.pendienteOperador:
        return const Color(0xFFE65100);
      case EstadoSolicitud.enAtencion:
        return const Color(0xFF1565C0);
      case EstadoSolicitud.enviada:
        return AppTheme.grisMedio;
      case EstadoSolicitud.enRevision:
        return const Color(0xFF1565C0);
      case EstadoSolicitud.pendiente:
        return const Color(0xFFE65100);
      case EstadoSolicitud.documentosPendientes:
        return const Color(0xFFE65100);
      case EstadoSolicitud.completa:
        return AppTheme.navy;
      case EstadoSolicitud.enComite:
        return AppTheme.navy;
      case EstadoSolicitud.aprobada:
        return AppTheme.verdeSaldo;
      case EstadoSolicitud.condicionada:
        return Colors.orange;
      case EstadoSolicitud.rechazada:
        return AppTheme.rojoError;
      case EstadoSolicitud.desembolsada:
        return const Color(0xFF2E7D32);
    }
  }

  IconData get icono {
    switch (this) {
      case EstadoSolicitud.pendienteOperador:
        return Icons.hourglass_top;
      case EstadoSolicitud.enAtencion:
        return Icons.support_agent;
      case EstadoSolicitud.enviada:
        return Icons.send;
      case EstadoSolicitud.enRevision:
        return Icons.search;
      case EstadoSolicitud.pendiente:
        return Icons.hourglass_empty;
      case EstadoSolicitud.documentosPendientes:
        return Icons.upload_file;
      case EstadoSolicitud.completa:
        return Icons.checklist;
      case EstadoSolicitud.enComite:
        return Icons.groups;
      case EstadoSolicitud.aprobada:
        return Icons.check_circle;
      case EstadoSolicitud.condicionada:
        return Icons.warning_amber;
      case EstadoSolicitud.rechazada:
        return Icons.cancel;
      case EstadoSolicitud.desembolsada:
        return Icons.account_balance;
    }
  }
}
