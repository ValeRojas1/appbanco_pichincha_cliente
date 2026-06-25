import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  String? _fcmToken;

  Future<void> inicializar(String clienteId) async {
    try {
      // Generar token FCM simulado para demo (evita colapsos por falta de google-services.json)
      _fcmToken = await _obtenerTokenFCM();
      if (_fcmToken != null) {
        await registrarToken(clienteId, _fcmToken!);
      }
    } catch (_) {
      // Fallback silencioso en caso de error
    }
  }

  Future<String> _obtenerTokenFCM() async {
    // Generador de token simulado con estructura real
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-:';
    final tokenPart = List.generate(140, (index) => chars[random.nextInt(chars.length)]).join();
    return 'fcm_token_client_$tokenPart';
  }

  Future<bool> registrarToken(String clienteId, String token) async {
    try {
      await _client.from('clientes_fcmtokens').upsert({
        'clienteid': clienteId,
        'token': token,
        'device_type': 'android',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'clienteid');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> eliminarToken(String clienteId) async {
    try {
      await _client
          .from('clientes_fcmtokens')
          .delete()
          .eq('clienteid', clienteId);
    } catch (_) {}
  }
}
