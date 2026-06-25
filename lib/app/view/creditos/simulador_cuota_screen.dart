import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/amortizacion_francesa.dart';
import '../../ui/theme/app_theme.dart';

class SimuladorCuotaScreen extends StatefulWidget {
  const SimuladorCuotaScreen({super.key});
  @override
  State<SimuladorCuotaScreen> createState() => _SimuladorCuotaScreenState();
}

class _SimuladorCuotaScreenState extends State<SimuladorCuotaScreen> {
  final _montoCtrl = TextEditingController(text: '5000');
  final _teaCtrl = TextEditingController(text: '28.5');
  int _plazo = 12;
  double _monto = 5000;
  double _tea = 28.5;

  double get _cuota => AmortizacionFrancesa.calcularCuota(_monto, _tea, _plazo);
  double get _totalIntereses => AmortizacionFrancesa.totalIntereses(_monto, _tea, _plazo);
  double get _totalPagar => _monto + _totalIntereses;

  void _calcular() {
    setState(() {
      _monto = double.tryParse(_montoCtrl.text) ?? 5000;
      _tea = double.tryParse(_teaCtrl.text) ?? 28.5;
    });
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _teaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Simulador de Cuota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.navy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.navy.withValues(alpha: 0.15)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppTheme.navy, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Simulación referencial. Los valores reales dependen de tu evaluación crediticia.',
                    style: TextStyle(fontSize: 13, color: AppTheme.navy),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            const Text('Parámetros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navy)),
            const SizedBox(height: 14),
            // Monto
            TextField(
              controller: _montoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                labelText: 'Monto del crédito (S/)',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
              onChanged: (_) => _calcular(),
            ),
            const SizedBox(height: 16),
            // Plazo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plazo: $_plazo meses',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.navy)),
                Slider(
                  value: _plazo.toDouble(),
                  min: 3,
                  max: 60,
                  divisions: 57,
                  activeColor: AppTheme.navy,
                  inactiveColor: AppTheme.navy.withValues(alpha: 0.2),
                  label: '$_plazo meses',
                  onChanged: (v) => setState(() => _plazo = v.round()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('3m', style: TextStyle(fontSize: 11, color: AppTheme.grisMedio)),
                      Text('60m', style: TextStyle(fontSize: 11, color: AppTheme.grisMedio)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TEA
            TextField(
              controller: _teaCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                labelText: 'TEA (%) — Tasa Efectiva Anual',
                prefixIcon: Icon(Icons.percent),
              ),
              onChanged: (_) => _calcular(),
            ),
            const SizedBox(height: 28),
            // Resultado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.navy, Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navy.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('Cuota Mensual Estimada',
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    'S/ ${_cuota.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.amarillo,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ResultItem('Total a Pagar', 'S/ ${_totalPagar.toStringAsFixed(2)}'),
                      _ResultItem('Total Intereses', 'S/ ${_totalIntereses.toStringAsFixed(2)}'),
                      _ResultItem('Plazo', '$_plazo meses'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tabla amortización (primeras 3 cuotas)
            const Text('Vista previa tabla de pagos',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navy)),
            const SizedBox(height: 12),
            ..._buildTablaPreview(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTablaPreview() {
    final tabla = AmortizacionFrancesa.generarTabla(_monto, _tea, _plazo);
    final preview = tabla.take(3).toList();
    return [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        ),
        child: Column(
          children: [
            _TablaHeader(),
            ...preview.map((r) => _TablaFila(r)),
            if (tabla.length > 3)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('... y ${tabla.length - 3} cuotas más',
                    style: const TextStyle(color: AppTheme.grisMedio, fontSize: 12)),
              ),
          ],
        ),
      ),
    ];
  }
}

class _ResultItem extends StatelessWidget {
  final String label, value;
  const _ResultItem(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    ]);
  }
}

class _TablaHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.grisClaro,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          Expanded(child: Text('Cuota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.navy))),
          Expanded(child: Text('Capital', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.navy))),
          Expanded(child: Text('Interés', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.navy))),
          Expanded(child: Text('Saldo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.navy))),
        ],
      ),
    );
  }
}

class _TablaFila extends StatelessWidget {
  final Map<String, dynamic> fila;
  const _TablaFila(this.fila);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.grisClaro)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('${fila['cuota']}', style: const TextStyle(fontSize: 12))),
          Expanded(child: Text('${(fila['capital'] as double).toStringAsFixed(1)}', style: const TextStyle(fontSize: 12))),
          Expanded(child: Text('${(fila['interes'] as double).toStringAsFixed(1)}', style: const TextStyle(fontSize: 12))),
          Expanded(child: Text('${(fila['saldoPendiente'] as double).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppTheme.navy))),
        ],
      ),
    );
  }
}
