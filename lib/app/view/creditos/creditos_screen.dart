import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/credito_viewmodel.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../model/credito_model.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/cliente_bottom_nav_bar.dart';
import '../../ui/widgets/cliente_app_bar_leading.dart';

class CreditosScreen extends StatefulWidget {
  const CreditosScreen({super.key});
  @override
  State<CreditosScreen> createState() => _CreditosScreenState();
}

class _CreditosScreenState extends State<CreditosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
      if (cliente != null) {
        Provider.of<CreditoViewModel>(context, listen: false)
            .cargarCreditos(cliente.id);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text('Mis Créditos'),
        leading: const ClienteAppBarLeading(),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Inicio',
            onPressed: () => irAlInicioCliente(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.amarillo,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [Tab(text: 'Activos'), Tab(text: 'Historial')],
        ),
      ),
      bottomNavigationBar: const ClienteBottomNavBar(selectedIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/simulador-cuota'),
        backgroundColor: AppTheme.amarillo,
        foregroundColor: AppTheme.navy,
        icon: const Icon(Icons.calculate_outlined),
        label: const Text('Simular Cuota', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<CreditoViewModel>(
        builder: (_, vm, __) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.navy));
          }
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _CreditosList(creditos: vm.creditosVigentes, activos: true),
              _CreditosList(creditos: vm.creditosHistorial, activos: false),
            ],
          );
        },
      ),
    );
  }
}

class _CreditosList extends StatelessWidget {
  final List<CreditoModel> creditos;
  final bool activos;

  const _CreditosList({required this.creditos, required this.activos});

  @override
  Widget build(BuildContext context) {
    if (creditos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(activos ? Icons.credit_score_outlined : Icons.history,
                size: 60, color: AppTheme.grisMedio),
            const SizedBox(height: 16),
            Text(
              activos
                  ? 'No tienes créditos activos en este momento'
                  : 'Aún no hay créditos en tu historial',
              style: const TextStyle(
                  color: AppTheme.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              activos
                  ? 'Cuando tengas un crédito vigente, lo verás aquí.'
                  : 'Tus créditos anteriores aparecerán en esta sección.',
              style: const TextStyle(color: AppTheme.grisMedio, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: creditos.length,
      itemBuilder: (_, i) => _TarjetaCredito(credito: creditos[i]),
    );
  }
}

class _TarjetaCredito extends StatelessWidget {
  final CreditoModel credito;
  const _TarjetaCredito({required this.credito});

  Color get _colorEstado {
    switch (credito.estado) {
      case 'vigente': return AppTheme.verdeSaldo;
      case 'moroso': return AppTheme.rojoError;
      default: return AppTheme.grisMedio;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/credito-detalle',
            arguments: credito),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(credito.numeroCredito,
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 15, color: AppTheme.navy)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _colorEstado.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      credito.estadoLabel.toUpperCase(),
                      style: TextStyle(color: _colorEstado,
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stat('Monto', 'S/ ${credito.monto.toStringAsFixed(0)}'),
                  const SizedBox(width: 20),
                  _Stat('Plazo', '${credito.plazoMeses} meses'),
                  const SizedBox(width: 20),
                  _Stat('TEA', '${credito.tea}%'),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: credito.monto > 0
                    ? (credito.monto - credito.saldoPendiente) / credito.monto
                    : 0,
                backgroundColor: AppTheme.grisClaro,
                color: credito.estaMoroso ? AppTheme.rojoError : AppTheme.verdeSaldo,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Saldo pendiente: S/ ${credito.saldoPendiente.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.grisMedio)),
                  Text('Desembolso: ${credito.fechaDesembolso}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.grisMedio)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.grisMedio)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navy)),
      ],
    );
  }
}
