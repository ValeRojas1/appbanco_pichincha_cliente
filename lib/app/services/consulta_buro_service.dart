import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/consulta_buro_model.dart';

class ConsultaBuroService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> verificarListaNegra(String documento) async {
    try {
      final data = await _client
          .from('listasnegras')
          .select('id')
          .eq('documento', documento)
          .eq('activo', true)
          .maybeSingle();
      return data != null;
    } catch (e) {
      return false;
    }
  }

  Future<ConsultaBuroModel?> consultarBuro(String documento, String firmaBase64) async {
    try {
      final response = await _client.functions.invoke(
        'consulta-buro',
        body: {
          'documento': documento,
          'firma_consentimiento': firmaBase64,
          'origen': 'app_cliente',
        },
      );
      if (response.data == null) return null;
      // Buscar la consulta recién creada
      final consulta = await _client
          .from('consultasburo')
          .select()
          .eq('documento', documento)
          .order('createdat', ascending: false)
          .limit(1)
          .single();
      return ConsultaBuroModel.fromJson(consulta);
    } catch (e) {
      return null;
    }
  }
}
