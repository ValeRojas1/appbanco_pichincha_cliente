import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/cuenta_model.dart';
import '../model/transaccion_model.dart';

class CuentaService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CuentaModel>> getCuentas(String userid) async {
    try {
      final response = await _client
          .from('cuentas')
          .select()
          .eq('userid', userid);
      return (response as List).map((e) => CuentaModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TransaccionModel>> getTransacciones(String userid) async {
    try {
      final response = await _client
          .from('transacciones')
          .select()
          .eq('userid', userid)
          .order('fecha', ascending: false);
      return (response as List).map((e) => TransaccionModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<double?> getSaldoTotal(String userid) async {
    try {
      final response = await _client
          .from('cuentas')
          .select('saldo')
          .eq('userid', userid);
      final cuentas = response as List;
      double total = 0;
      for (var c in cuentas) {
        total += (c['saldo'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      return null;
    }
  }
}
