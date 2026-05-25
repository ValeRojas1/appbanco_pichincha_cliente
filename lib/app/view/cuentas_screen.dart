import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cuenta_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';
import '../ui/theme/app_theme.dart';

class CuentasScreen extends StatefulWidget {
  const CuentasScreen({super.key});

  @override
  State<CuentasScreen> createState() => _CuentasScreenState();
}

class _CuentasScreenState extends State<CuentasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<HomeViewModel>(context, listen: false).usuario;
      if (user != null) {
        Provider.of<CuentaViewModel>(context, listen: false)
            .cargarCuentas(user.userid);
      }
    });
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'corriente': return Icons.account_balance;
      case 'ahorro': return Icons.savings;
      default: return Icons.credit_card;
    }
  }

  String _nombrePorTipo(String tipo) {
    switch (tipo) {
      case 'corriente': return 'Cuenta Corriente';
      case 'ahorro': return 'Cuenta de Ahorros';
      default: return 'Cuenta de Crédito';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CuentaViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Mis Cuentas')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.navy))
          : vm.cuentas.isEmpty
              ? const Center(child: Text('No tienes cuentas registradas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.cuentas.length,
                  itemBuilder: (_, i) {
                    final c = vm.cuentas[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.navy,
                          child: Icon(
                            _iconoPorTipo(c.tipocuenta),
                            color: AppTheme.amarillo,
                          ),
                        ),
                        title: Text(
                          _nombrePorTipo(c.tipocuenta),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: AppTheme.navy),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.numerocuenta != null)
                              Text(c.numerocuenta!,
                                  style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '${c.moneda} ${c.saldo.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.verdeSaldo,
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
