import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cuenta_service.dart';
import '../viewmodel/home_viewmodel.dart';
import '../viewmodel/credito_viewmodel.dart';
import '../model/transaccion_model.dart';
import '../model/cuenta_model.dart';
import '../model/credito_model.dart';
import '../ui/theme/app_theme.dart';

class TransaccionesScreen extends StatefulWidget {
  const TransaccionesScreen({super.key});

  @override
  State<TransaccionesScreen> createState() => _TransaccionesScreenState();
}

class _TransaccionesScreenState extends State<TransaccionesScreen> with TickerProviderStateMixin {
  final CuentaService _cuentaService = CuentaService();
  TabController? _tabController;
  List<dynamic> _tabsItems = []; // Puede contener CuentaModel o CreditoModel
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final homeVm = Provider.of<HomeViewModel>(context, listen: false);
    final creditoVm = Provider.of<CreditoViewModel>(context, listen: false);
    final cliente = homeVm.cliente;
    if (cliente == null) return;

    if (homeVm.cuentas.isEmpty) {
      await homeVm.recargar();
    }
    await creditoVm.cargarCreditos(cliente.id);

    _tabsItems = [];
    _tabsItems.addAll(homeVm.cuentas);
    _tabsItems.addAll(creditoVm.creditos);

    if (_tabsItems.isNotEmpty) {
      _tabController = TabController(length: _tabsItems.length, vsync: this);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.grisClaro,
        appBar: AppBar(title: const Text('Historial')),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.navy),
        ),
      );
    }

    if (_tabsItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.grisClaro,
        appBar: AppBar(title: const Text('Historial')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'No tienes cuentas ni créditos activos para ver su historial.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grisMedio, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: _tabsItems.length > 2,
          indicatorColor: AppTheme.amarillo,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: _tabsItems.map((item) {
            if (item is CuentaModel) {
              final String tipoLabel = item.tipocuenta == 'ahorro' ? 'Ahorros' : 'Corriente';
              final String numLabel = item.numerocuenta != null && item.numerocuenta!.length >= 4
                  ? '...${item.numerocuenta!.substring(item.numerocuenta!.length - 4)}'
                  : '';
              return Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tipoLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (numLabel.isNotEmpty)
                      Text(numLabel, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  ],
                ),
              );
            } else if (item is CreditoModel) {
              final String numLabel = item.numeroCredito.length >= 4
                  ? '...${item.numeroCredito.substring(item.numeroCredito.length - 4)}'
                  : '';
              return Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Crédito', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (numLabel.isNotEmpty)
                      Text(numLabel, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  ],
                ),
              );
            }
            return const Tab(text: 'Desconocido');
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabsItems.map((item) {
          if (item is CuentaModel) {
            return _buildTransaccionesCuentaList(item);
          } else if (item is CreditoModel) {
            return _buildPagosCreditoList(item);
          }
          return const Center(child: Text('Datos no disponibles'));
        }).toList(),
      ),
    );
  }

  Widget _buildTransaccionesCuentaList(CuentaModel cuenta) {
    return FutureBuilder<List<TransaccionModel>>(
      future: _cuentaService.getTransaccionesPorCuenta(cuenta.cuentaid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.navy));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Ocurrió un error al cargar las transacciones.'));
        }

        final txns = snapshot.data ?? [];
        if (txns.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Esta cuenta aún no registra movimientos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.grisMedio, fontSize: 14),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: txns.length,
            itemBuilder: (_, i) {
              final t = txns[i];
              final isIngreso = t.tipotransaccion == 'credito';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIngreso
                        ? AppTheme.verdeSaldo.withValues(alpha: 0.1)
                        : AppTheme.rojoError.withValues(alpha: 0.1),
                    child: Icon(
                      isIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIngreso ? AppTheme.verdeSaldo : AppTheme.rojoError,
                    ),
                  ),
                  title: Text(
                    t.descripcion.isNotEmpty ? t.descripcion : t.tipotransaccion,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    t.fecha != null
                        ? '${t.fecha!.day.toString().padLeft(2, '0')}/${t.fecha!.month.toString().padLeft(2, '0')}/${t.fecha!.year}'
                        : 'Fecha no disponible',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    '${isIngreso ? '+' : '-'}S/ ${t.monto.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIngreso ? AppTheme.verdeSaldo : AppTheme.rojoError,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPagosCreditoList(CreditoModel credito) {
    final creditoVm = Provider.of<CreditoViewModel>(context);
    final pagos = creditoVm.pagos.where((p) => p.clienteId == credito.clienteId).toList();

    if (pagos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No se registran pagos para este crédito.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grisMedio, fontSize: 14),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => creditoVm.cargarCreditos(credito.clienteId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pagos.length,
        itemBuilder: (_, i) {
          final p = pagos[i];
          final color = p.estaPuntual ? AppTheme.verdeSaldo : AppTheme.rojoError;
          final icon = p.estaPuntual ? Icons.check_circle : Icons.warning_rounded;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.periodo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.navy)),
                    if (p.diasMora > 0)
                      Text('${p.diasMora} días de atraso',
                          style: const TextStyle(fontSize: 12, color: AppTheme.rojoError)),
                  ],
                ),
                const Spacer(),
                Text('S/ ${p.montoPagado.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
              ],
            ),
          );
        },
      ),
    );
  }
}
