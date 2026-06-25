import 'package:flutter/material.dart';
import 'package:appbanco_pichincha_cliente/app/ui/theme/app_theme.dart';

class AlertaCarteraModel {
  final String id;
  final String clienteId;
  final String titulo;
  final String mensaje;
  final String severidad;
  final bool leida;
  final DateTime createdat;

  AlertaCarteraModel({
    required this.id,
    required this.clienteId,
    required this.titulo,
    required this.mensaje,
    required this.severidad,
    required this.leida,
    required this.createdat,
  });

  Color get colorSeveridad {
    switch (severidad) {
      case 'critical':
        return AppTheme.rojoError;
      case 'warning':
        return const Color(0xFFE65100);
      default:
        return AppTheme.navy;
    }
  }

  IconData get iconoSeveridad {
    switch (severidad) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning_amber;
      default:
        return Icons.info_outline;
    }
  }

  factory AlertaCarteraModel.fromJson(Map<String, dynamic> json) {
    return AlertaCarteraModel(
      id: json['id'] ?? '',
      clienteId: json['clienteid'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      severidad: json['severidad'] ?? 'info',
      leida: json['leida'] ?? false,
      createdat: DateTime.tryParse(json['createdat'] ?? '') ?? DateTime.now(),
    );
  }
}
