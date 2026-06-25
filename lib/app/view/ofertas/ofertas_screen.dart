import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/ofertas_viewmodel.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../ui/theme/app_theme.dart';

class OfertasScreen extends StatefulWidget {
  final int initialTab;
  const OfertasScreen({super.key, this.initialTab = 0});

  @override
  State<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
      if (cliente != null) {
        Provider.of<OfertasViewModel>(context, listen: false).cargar(cliente.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text('Ofertas y Notificaciones'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.amarillo,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Mis Ofertas', icon: Icon(Icons.local_offer_outlined)),
            Tab(text: 'Alertas', icon: Icon(Icons.notifications_active_outlined)),
          ],
        ),
      ),
      body: Consumer<OfertasViewModel>(
        builder: (_, vm, __) {
          if (vm.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.navy),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOfertasTab(vm),
              _buildAlertasTab(vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfertasTab(OfertasViewModel vm) {
    if (!vm.tienePreaprobado && vm.campanas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_outlined, size: 70, color: AppTheme.grisMedio),
            const SizedBox(height: 16),
            const Text(
              'Por ahora no tienes ofertas activas',
              style: TextStyle(
                  color: AppTheme.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando tengamos una oferta para ti,\nla verás aquí de inmediato.',
              style: TextStyle(color: AppTheme.grisMedio, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vm.tienePreaprobado) ...[
          const Text(
            'Tu Crédito Preaprobado',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navy),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.navy, Color(0xFF1E3C72)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navy.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.amarillo,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PREAPROBADO',
                        style: TextStyle(
                            color: AppTheme.navy,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.star_rounded, color: AppTheme.amarillo, size: 28),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'S/ ${vm.preaprobado!.montoPreaprobado.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Monto máximo disponible',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPreDetail(
                        'Plazo', '${vm.preaprobado!.plazoMeses} meses'),
                    _buildPreDetail('TEA', '${vm.preaprobado!.tea}%'),
                    _buildPreDetail(
                        'Cuota Est.',
                        'S/ ${vm.preaprobado!.cuotaEstimada?.toStringAsFixed(2) ?? "---"}'),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white60, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Válido hasta: ${vm.preaprobado!.vigenteHasta}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/consentimiento');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.amarillo,
                      foregroundColor: AppTheme.navy,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Solicitar ahora',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (vm.campanas.isNotEmpty) ...[
          const Text(
            'Campañas y Promociones',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navy),
          ),
          const SizedBox(height: 12),
          ...vm.campanas.map((c) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppTheme.amarillo.withValues(alpha: 0.15),
                        child: const Icon(Icons.campaign, color: AppTheme.navy),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.tipoCampana,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navy),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Campaña exclusiva para ti: S/ ${c.montoOferta.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.grisMedio),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vence: ${c.fechaVencimiento}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.grisMedio),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/preevaluacion');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Ver', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildPreDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }

  Widget _buildAlertasTab(OfertasViewModel vm) {
    if (vm.alertas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_outlined,
                size: 70, color: AppTheme.grisMedio),
            const SizedBox(height: 16),
            const Text(
              'Todo al día — sin alertas pendientes',
              style: TextStyle(
                  color: AppTheme.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.alertas.length,
      itemBuilder: (_, i) {
        final a = vm.alertas[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                  color: a.leida
                      ? Colors.transparent
                      : a.colorSeveridad.withValues(alpha: 0.3))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(a.iconoSeveridad, color: a.colorSeveridad),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            a.titulo,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: a.leida ? AppTheme.grisMedio : AppTheme.navy),
                          ),
                          if (!a.leida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: AppTheme.rojoError,
                                  shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.mensaje,
                        style: TextStyle(
                            fontSize: 13,
                            color: a.leida ? AppTheme.grisMedio : AppTheme.navyOscuro),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recibido: ${_formatDateTime(a.createdat)}',
                        style: TextStyle(fontSize: 11, color: AppTheme.grisMedio),
                      ),
                      if (!a.leida) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => vm.marcarAlertaLeida(a.id),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              alignment: Alignment.centerLeft),
                          child: const Text(
                            'Marcar como leída',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.navy),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
