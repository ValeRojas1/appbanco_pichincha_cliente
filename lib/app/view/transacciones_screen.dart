import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cuenta_service.dart';
import '../viewmodel/home_viewmodel.dart';
import '../model/transaccion_model.dart';
import '../ui/theme/app_theme.dart';

class TransaccionesScreen extends StatefulWidget {
  const TransaccionesScreen({super.key});

  @override
  State<TransaccionesScreen> createState() => _TransaccionesScreenState();
}

class _TransaccionesScreenState extends State<TransaccionesScreen> {
  final CuentaService _cuentaService = CuentaService();
  List<TransaccionModel> _transacciones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarTransacciones();
  }

  Future<void> _cargarTransacciones() async {
    final user =
        Provider.of<HomeViewModel>(context, listen: false).usuario;
    if (user == null) return;
    final txns = await _cuentaService.getTransacciones(user.userid);
    setState(() {
      _transacciones = txns;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Historial de Transacciones')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.navy))
          : _transacciones.isEmpty
              ? const Center(child: Text('No hay transacciones'))
              : RefreshIndicator(
                  onRefresh: _cargarTransacciones,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transacciones.length,
                    itemBuilder: (_, i) {
                      final t = _transacciones[i];
                      final isIngreso = t.tipotransaccion == 'credito';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIngreso
                                ? AppTheme.verdeSaldo.withValues(alpha: 0.1)
                                : AppTheme.rojoError.withValues(alpha: 0.1),
                            child: Icon(
                              isIngreso
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color:
                                  isIngreso ? AppTheme.verdeSaldo : AppTheme.rojoError,
                            ),
                          ),
                          title: Text(
                            t.descripcion.isNotEmpty
                                ? t.descripcion
                                : t.tipotransaccion,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            t.fecha != null
                                ? '${t.fecha!.day}/${t.fecha!.month}/${t.fecha!.year}'
                                : 'Fecha no disponible',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${isIngreso ? '+' : '-'}S/ ${t.monto.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isIngreso
                                  ? AppTheme.verdeSaldo
                                  : AppTheme.rojoError,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
