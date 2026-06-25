import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/preevaluacion_result_model.dart';

class PreEvaluacionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<PreEvaluacionResultadoModel> preEvaluar({
    required String dni,
    required double ingresos,
    required String tipoNegocio,
    required double monto,
    required String destino,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'pre-evaluar',
        body: {
          'dni': dni,
          'ingresos': ingresos,
          'tiponegocio': tipoNegocio,
          'monto': monto,
          'destino': destino,
          'origen': 'app_cliente',
        },
      );
      if (response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        return PreEvaluacionResultadoModel.fromJson({
          ...data,
          'monto': monto,
          'dni': dni,
        });
      }
    } catch (_) {
      // Fallback local si la Edge Function no responde.
    }

    return _evaluarLocal(
      dni: dni,
      ingresos: ingresos,
      monto: monto,
      destino: destino,
    );
  }

  /// Misma lógica que la Edge Function `pre-evaluar` (app ventas).
  PreEvaluacionResultadoModel _evaluarLocal({
    required String dni,
    required double ingresos,
    required double monto,
    required String destino,
  }) {
    final ing = ingresos < 1 ? 1 : ingresos;
    final ratio = monto / ing;
    final dest = destino.toLowerCase();

    if (monto < 500 || monto > 50000) {
      return PreEvaluacionResultadoModel(
        resultado: 'NO PROCEDE',
        mensaje: 'Monto fuera del rango permitido (S/ 500 – S/ 50,000).',
        monto: monto,
        dni: dni,
        evaluacionLocal: true,
      );
    }
    if (ratio > 4 || ingresos < 800) {
      return PreEvaluacionResultadoModel(
        resultado: 'NO PROCEDE',
        mensaje: 'Capacidad de pago insuficiente con los datos ingresados.',
        monto: monto,
        dni: dni,
        evaluacionLocal: true,
      );
    }
    if (ratio > 2.5 || (dest.contains('invers') && ratio > 2)) {
      return PreEvaluacionResultadoModel(
        resultado: 'REVISAR',
        mensaje:
            'Tu perfil requiere revisión adicional. Puedes solicitar crédito y un operador te evaluará en visita.',
        monto: monto,
        dni: dni,
        evaluacionLocal: true,
      );
    }
    if (ratio > 1.8) {
      return PreEvaluacionResultadoModel(
        resultado: 'REVISAR',
        mensaje:
            'Pre-evaluación favorable con observaciones. Un operador confirmará los detalles contigo.',
        monto: monto,
        dni: dni,
        evaluacionLocal: true,
      );
    }
    return PreEvaluacionResultadoModel(
      resultado: 'APTO',
      mensaje:
          'Pre-evaluación preliminar favorable. Puedes solicitar crédito con un asesor.',
      monto: monto,
      dni: dni,
      evaluacionLocal: true,
    );
  }
}
