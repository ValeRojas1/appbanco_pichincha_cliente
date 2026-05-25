import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/cuenta_ahorro_model.dart';

class AhorroService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<CuentaAhorroModel?> getCuentaAhorro(String userid) async {
    try {
      final response = await _client
          .from('cuentasahorro')
          .select()
          .eq('userid', userid)
          .maybeSingle();
      if (response == null) return null;
      return CuentaAhorroModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
