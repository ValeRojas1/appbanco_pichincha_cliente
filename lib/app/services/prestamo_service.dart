import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/solicitud_prestamo_model.dart';

class PrestamoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<SolicitudPrestamoModel>> getSolicitudes(String userid) async {
    try {
      final response = await _client
          .from('solicitudesprestamo')
          .select()
          .eq('userid', userid)
          .order('createdat', ascending: false);
      return (response as List).map((e) => SolicitudPrestamoModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<SolicitudPrestamoModel?> crearSolicitud(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('solicitudesprestamo')
          .insert(data)
          .select()
          .single();
      return SolicitudPrestamoModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
