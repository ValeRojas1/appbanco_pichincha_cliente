import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/notificacion_solicitud_viewmodel.dart';
import '../ui/widgets/notificaciones_solicitud_dialog.dart';

/// Revisa novedades de solicitudes al abrir o volver a la app.
Future<void> revisarNotificacionesSolicitud(
  BuildContext context, {
  bool mostrarDialogo = true,
}) async {
  final cliente = context.read<AuthViewModel>().cliente;
  if (cliente == null) return;

  final nvm = context.read<NotificacionSolicitudViewModel>();
  await nvm.revisarAlEntrar(cliente.documento);

  if (!context.mounted || !mostrarDialogo || nvm.pendientes.isEmpty) return;

  await mostrarNotificacionesSolicitudDialog(context);

  if (context.mounted) {
    await nvm.marcarComoVistas(cliente.documento);
  }
}
