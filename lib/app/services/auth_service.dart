import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/usuario_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UsuarioModel?> login(String dni, String password) async {
    try {
      final response = await _client
          .from('usuariosmock')
          .select()
          .eq('dni', dni)
          .eq('passwordhash', password)
          .eq('rol', 'cliente')
          .single();
      return UsuarioModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
