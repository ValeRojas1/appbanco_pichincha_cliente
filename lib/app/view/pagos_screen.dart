import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/pago_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';
import '../ui/theme/app_theme.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cliente = Provider.of<HomeViewModel>(context, listen: false).cliente;
      if (cliente != null) {
        Provider.of<PagoViewModel>(context, listen: false)
            .cargarPagos(cliente.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PagoViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Mis Pagos')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.navy))
          : vm.pagos.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aún no tienes pagos registrados.\nCuando realices uno, aparecerá aquí automáticamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.grisMedio, fontSize: 14),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.pagos.length,
                  itemBuilder: (_, i) {
                    final p = vm.pagos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.navy,
                          child: const Icon(Icons.receipt,
                              color: AppTheme.amarillo),
                        ),
                        title: Text(p.servicio[0].toUpperCase() + p.servicio.substring(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${p.numerocontrato} - ${p.fecha != null ? '${p.fecha!.day}/${p.fecha!.month}/${p.fecha!.year}' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'S/ ${p.monto.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.rojoError,
                              ),
                            ),
                            Text(
                              p.estado,
                              style: TextStyle(
                                fontSize: 11,
                                color: p.estado == 'completado'
                                    ? AppTheme.verdeSaldo
                                    : AppTheme.grisMedio,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
