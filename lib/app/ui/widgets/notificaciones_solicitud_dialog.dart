import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/notificacion_solicitud_local.dart';
import '../../viewmodel/notificacion_solicitud_viewmodel.dart';
import '../theme/app_theme.dart';

Future<void> mostrarNotificacionesSolicitudDialog(BuildContext context) async {
  final nvm = context.read<NotificacionSolicitudViewModel>();
  if (nvm.pendientes.isEmpty) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _NotificacionesSolicitudDialog(notificaciones: nvm.pendientes),
  );
}

class _NotificacionesSolicitudDialog extends StatelessWidget {
  final List<NotificacionSolicitudLocal> notificaciones;

  const _NotificacionesSolicitudDialog({required this.notificaciones});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.navy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.mark_email_unread_outlined, color: AppTheme.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notificaciones.length == 1
                  ? 'Tienes una novedad'
                  : 'Tienes ${notificaciones.length} novedades',
              style: const TextStyle(fontSize: 18, color: AppTheme.navy),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: notificaciones.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _TarjetaNotificacion(notificacion: notificaciones[i]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/solicitudes');
          },
          child: const Text('Ver solicitudes'),
        ),
      ],
    );
  }
}

class _TarjetaNotificacion extends StatelessWidget {
  final NotificacionSolicitudLocal notificacion;

  const _TarjetaNotificacion({required this.notificacion});

  @override
  Widget build(BuildContext context) {
    final estado = notificacion.estadoEnum;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: estado.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: estado.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(estado.icono, color: estado.color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificacion.titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: estado.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${notificacion.monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grisMedio,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notificacion.mensaje,
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
