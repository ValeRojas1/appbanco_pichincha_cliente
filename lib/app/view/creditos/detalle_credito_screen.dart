import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/credito_viewmodel.dart';
import '../../model/credito_model.dart';
import '../../model/pago_mensual_model.dart';
import '../../ui/theme/app_theme.dart';

class DetalleCreditoScreen extends StatelessWidget {
  const DetalleCreditoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final credito = ModalRoute.of(context)!.settings.arguments as CreditoModel;
    final vm = Provider.of<CreditoViewModel>(context, listen: false);
    final pagos = vm.pagos.where((p) => p.clienteId == credito.clienteId).take(12).toList();

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: Text(credito.numeroCredito)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: credito.estaMoroso
                      ? [AppTheme.rojoError, const Color(0xFFB71C1C)]
                      : [AppTheme.navy, const Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (credito.estaMoroso ? AppTheme.rojoError : AppTheme.navy)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(credito.numeroCredito,
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(credito.estadoLabel.toUpperCase(),
                            style: const TextStyle(color: Colors.white,
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('S/ ${credito.monto.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Monto desembolsado',
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: credito.monto > 0
                        ? (credito.monto - credito.saldoPendiente) / credito.monto
                        : 0,
                    backgroundColor: Colors.white24,
                    color: AppTheme.amarillo,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pagado: S/ ${(credito.monto - credito.saldoPendiente).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        'Saldo: S/ ${credito.saldoPendiente.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Detalles
            _seccionTitulo('Detalles del Crédito'),
            const SizedBox(height: 12),
            _tarjetaInfo([
              _item('Plazo', '${credito.plazoMeses} meses'),
              _item('TEA', '${credito.tea}%'),
              _item('Fecha Desembolso', credito.fechaDesembolso),
              _item('N° Crédito', credito.numeroCredito),
            ]),
            const SizedBox(height: 20),
            // Historial de pagos
            _seccionTitulo('Historial de Pagos (últimos 12)'),
            const SizedBox(height: 12),
            if (pagos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      'Los pagos de este crédito aparecerán aquí\nconforme los realices.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.grisMedio, fontSize: 13)),
                ),
              )
            else
              ...pagos.map((p) => _PagoItem(pago: p)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _seccionTitulo(String titulo) =>
      Text(titulo, style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navy));

  Widget _tarjetaInfo(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.grisMedio, fontSize: 14)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navy)),
        ],
      ),
    );
  }
}

class _PagoItem extends StatelessWidget {
  final PagoMensualModel pago;
  const _PagoItem({required this.pago});

  @override
  Widget build(BuildContext context) {
    final color = pago.estaPuntual ? AppTheme.verdeSaldo : AppTheme.rojoError;
    final icon = pago.estaPuntual ? Icons.check_circle : Icons.warning_rounded;
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
              Text(pago.periodo,
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 14, color: AppTheme.navy)),
              if (pago.diasMora > 0)
                Text('${pago.diasMora} días de atraso',
                    style: const TextStyle(fontSize: 12, color: AppTheme.rojoError)),
            ],
          ),
          const Spacer(),
          Text('S/ ${pago.montoPagado.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        ],
      ),
    );
  }
}
