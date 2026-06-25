import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/credito_preaprobado_model.dart';
import '../model/campana_activa_model.dart';
import '../model/alerta_cartera_model.dart';

class OfertasService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<CreditoPreaprobadoModel?> getPreaprobado(String clienteId) async {
    try {
      final data = await _client
          .from('creditospreaprobados')
          .select()
          .eq('clienteid_ficha', clienteId)
          .eq('vigente', true)
          .maybeSingle();
      if (data == null) return null;
      return CreditoPreaprobadoModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<CampanaActivaModel>> getCampanas(String clienteId) async {
    try {
      final data = await _client
          .from('campanasactivas')
          .select()
          .eq('clienteid', clienteId)
          .eq('activa', true)
          .order('createdat', ascending: false);
      return (data as List).map((e) => CampanaActivaModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<AlertaCarteraModel>> getAlertas(String clienteId) async {
    try {
      final data = await _client
          .from('alertascartera')
          .select()
          .eq('clienteid', clienteId)
          .order('createdat', ascending: false);
      return (data as List).map((e) => AlertaCarteraModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> marcarAlertaLeida(String alertaId) async {
    try {
      await _client
          .from('alertascartera')
          .update({'leida': true}).eq('id', alertaId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
