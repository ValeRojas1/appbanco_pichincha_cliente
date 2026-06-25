import 'package:flutter/material.dart';
import '../../model/consulta_buro_model.dart';
import '../../ui/theme/app_theme.dart';

class ResultadoBuroScreen extends StatelessWidget {
  const ResultadoBuroScreen({super.key});

  Color _colorSbs(String? sbs) {
    switch (sbs) {
      case 'Normal':
        return AppTheme.verdeSaldo;
      case 'CPP':
        return AppTheme.amarillo;
      case 'Deficiente':
        return const Color(0xFFE65100);
      case 'Dudoso':
      case 'Pérdida':
        return AppTheme.rojoError;
      default:
        return AppTheme.grisMedio;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultado = ModalRoute.of(context)?.settings.arguments as ConsultaBuroModel?;

    if (resultado == null) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No encontramos los resultados.\nRegresa e intenta la consulta nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grisMedio, fontSize: 14),
            ),
          ),
        ),
      );
    }

    final sbsColor = _colorSbs(resultado.clasificacionSbs);

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Resultado de tu consulta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Success Header Icon
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.check_circle_rounded, color: AppTheme.verdeSaldo, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Consulta completada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.navy),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tu información crediticia fue consultada de forma segura. Revisa el resumen a continuación.',
              style: TextStyle(fontSize: 13, color: AppTheme.grisMedio),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Card SBS Classification
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Clasificación en Centrales (SBS)',
                    style: TextStyle(fontSize: 13, color: AppTheme.grisMedio),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resultado.clasificacionSbs ?? 'Sin clasificar',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: sbsColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: sbsColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  _rowDetail('Deuda Total Reportada', 'S/ ${resultado.deudaTotal.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _rowDetail('Días de atraso histórico', '${resultado.diasMoraHistorica} días'),
                  const Divider(height: 24),
                  _rowDetail('Registro interno del banco', resultado.enListaNegra ? 'Sí' : 'No'),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Action CTAs
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/preevaluacion');
                },
                child: const Text('Continuar con la evaluación'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Volver al inicio',
                style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.grisMedio, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navy, fontSize: 14)),
      ],
    );
  }
}
