import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/credito_model.dart';
import '../model/pago_mensual_model.dart';

class CreditoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CreditoModel>> getCreditosCliente(String clienteId) async {
    try {
      final data = await _client
          .from('creditos')
          .select()
          .eq('clienteid', clienteId)
          .order('fechadesembolso', ascending: false);
      return (data as List).map((e) => CreditoModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PagoMensualModel>> getPagosMensuales(String clienteId, {int limite = 12}) async {
    try {
      final data = await _client
          .from('pagosmensuales')
          .select()
          .eq('clienteid', clienteId)
          .order('periodo', ascending: false)
          .limit(limite);
      return (data as List).map((e) => PagoMensualModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
