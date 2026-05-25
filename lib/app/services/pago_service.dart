import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/pago_model.dart';

class PagoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PagoModel>> getPagos(String userid) async {
    try {
      final response = await _client
          .from('pagos')
          .select()
          .eq('userid', userid)
          .order('fecha', ascending: false);
      return (response as List).map((e) => PagoModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PagoModel?> registrarPago(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('pagos')
          .insert(data)
          .select()
          .single();
      return PagoModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
