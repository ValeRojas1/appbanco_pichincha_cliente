import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/solicitud_credito_viewmodel.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../model/solicitud_credito_model.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/cliente_bottom_nav_bar.dart';
import '../../ui/widgets/cliente_app_bar_leading.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});
  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  void _cargar() {
    final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
    if (cliente != null) {
      Provider.of<SolicitudCreditoViewModel>(context, listen: false)
          .cargarSolicitudes(cliente.documento);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        leading: const ClienteAppBarLeading(),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Inicio',
            onPressed: () => irAlInicioCliente(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/preevaluacion'),
        backgroundColor: AppTheme.amarillo,
        foregroundColor: AppTheme.navy,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva solicitud',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const ClienteBottomNavBar(selectedIndex: 0),
      body: Consumer<SolicitudCreditoViewModel>(
        builder: (_, vm, __) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.navy));
          }
          if (vm.solicitudes.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (cliente != null) await vm.recargar(cliente.documento);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Icon(Icons.description_outlined, size: 70, color: AppTheme.grisMedio),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no tienes solicitudes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Completa la pre-evaluación y solicita un crédito con un asesor.',
                      style: TextStyle(color: AppTheme.grisMedio, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/preevaluacion'),
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Ir a pre-evaluación'),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              if (cliente != null) await vm.recargar(cliente.documento);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: vm.solicitudes.length,
              itemBuilder: (_, i) => _TarjetaSolicitud(
                solicitud: vm.solicitudes[i],
                onTap: () async {
                  await vm.seleccionarSolicitud(vm.solicitudes[i]);
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/solicitud-detalle');
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaSolicitud extends StatelessWidget {
  final SolicitudCreditoModel solicitud;
  final VoidCallback onTap;
  const _TarjetaSolicitud({required this.solicitud, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final estado = solicitud.estadoEnum;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: estado.color.withValues(alpha: 0.12),
                    child: Icon(estado.icono, color: estado.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'S/ ${solicitud.monto.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navy),
                        ),
                        Text(
                          '${solicitud.plazoMeses} meses — TEA ${solicitud.tea}%',
                          style: const TextStyle(fontSize: 13, color: AppTheme.grisMedio),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: estado.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: estado.color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      estado.label,
                      style: TextStyle(
                          color: estado.color, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                estado.mensajeCliente,
                style: TextStyle(
                  fontSize: 12,
                  color: estado.color.withValues(alpha: 0.85),
                  height: 1.3,
                ),
              ),
              if (solicitud.numeroExpediente != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.folder_outlined, size: 15, color: AppTheme.grisMedio),
                    const SizedBox(width: 6),
                    Text('Exp: ${solicitud.numeroExpediente}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.grisMedio)),
                    if (solicitud.analistaAsignado != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.person_outline, size: 15, color: AppTheme.grisMedio),
                      const SizedBox(width: 4),
                      Text(solicitud.analistaAsignado!,
                          style: const TextStyle(fontSize: 12, color: AppTheme.grisMedio)),
                    ],
                  ],
                ),
              ],
              if (solicitud.motivoRechazo != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.rojoError.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline, size: 14, color: AppTheme.rojoError),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(solicitud.motivoRechazo!,
                          style: const TextStyle(fontSize: 12, color: AppTheme.rojoError)),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
