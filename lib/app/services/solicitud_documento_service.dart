import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/solicitud_documento_model.dart';

class SolicitudDocumentoService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _bucket = 'documentos-solicitudes';

  Future<List<SolicitudDocumentoModel>> getDocumentos(String solicitudId) async {
    try {
      final data = await _client
          .from('solicitudesdocumentos')
          .select()
          .eq('solicitudid', solicitudId)
          .order('tipodocumento');
      return (data as List).map((e) => SolicitudDocumentoModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> getUrlDocumento(String storagePath) async {
    try {
      final url = _client.storage.from(_bucket).getPublicUrl(storagePath);
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<bool> subirDocumento(String solicitudId, String tipo, File archivo) async {
    try {
      final path = '$solicitudId/$tipo.jpg';
      final bytes = await archivo.readAsBytes();
      await _client.storage.from(_bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      // Actualizar estado del documento en tabla
      await _client.from('solicitudesdocumentos').upsert({
        'solicitudid': solicitudId,
        'tipodocumento': tipo,
        'storagepath': path,
        'estado': 'listo',
        'obligatorio': true,
      }, onConflict: 'solicitudid,tipodocumento');
      return true;
    } catch (e) {
      return false;
    }
  }
}
