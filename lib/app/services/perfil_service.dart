import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/cliente_model.dart';

class PerfilService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ClienteModel?> getPerfil(String clienteId) async {
    try {
      final data = await _client
          .from('clientes')
          .select()
          .eq('id', clienteId)
          .maybeSingle();
      if (data == null) return null;
      return ClienteModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPosicionFinanciera(String documento) async {
    try {
      final response = await _client.functions.invoke(
        'consulta-posicion',
        body: {'documento': documento},
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
