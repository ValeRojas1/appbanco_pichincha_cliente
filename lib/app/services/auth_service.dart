import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/cliente_model.dart';
import '../core/auth_constants.dart';

class RegisterResult {
  final bool success;
  final ClienteModel? cliente;
  final String? errorMessage;
  final bool requiereConfirmacion;

  const RegisterResult({
    required this.success,
    this.cliente,
    this.errorMessage,
    this.requiereConfirmacion = false,
  });
}

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ClienteModel?> login(String dni, String password) async {
    try {
      final email = AuthConstants.emailFromDni(dni);
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) return null;
      return await _getPerfilCliente(response.user!.id, dni);
    } catch (e) {
      return null;
    }
  }

  Future<RegisterResult> registrar({
    required String correo,
    required String dni,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  }) async {
    try {
      final dniExistente = await _client
          .from('clientes')
          .select('id')
          .eq('documento', dni)
          .maybeSingle();
      if (dniExistente != null) {
        return const RegisterResult(
          success: false,
          errorMessage:
              'Ya existe una cuenta registrada con este DNI. Si ya tienes cuenta, inicia sesión.',
        );
      }

      final correoExistente = await _client
          .from('clientes')
          .select('id')
          .eq('correo', correo.trim().toLowerCase())
          .maybeSingle();
      if (correoExistente != null) {
        return const RegisterResult(
          success: false,
          errorMessage:
              'Este correo electrónico ya está registrado. Intenta con otro o inicia sesión.',
        );
      }

      final authEmail = AuthConstants.emailFromDni(dni);
      final signUpResponse = await _client.auth.signUp(
        email: authEmail,
        password: password,
        data: {
          'correo': correo.trim().toLowerCase(),
          'dni': dni,
          'nombres': nombres.trim(),
          'apellidos': apellidos.trim(),
        },
      );

      final user = signUpResponse.user;
      if (user == null) {
        return const RegisterResult(
          success: false,
          errorMessage:
              'No pudimos crear tu cuenta. Verifica tus datos e inténtalo de nuevo.',
        );
      }

      final clienteData = await _client
          .from('clientes')
          .insert({
            'documento': dni,
            'nombres': nombres.trim(),
            'apellidos': apellidos.trim(),
            'telefono': telefono.trim(),
            'correo': correo.trim().toLowerCase(),
            'auth_user_id': user.id,
          })
          .select()
          .single();

      final cliente = ClienteModel.fromJson(clienteData);
      final requiereConfirmacion = signUpResponse.session == null;

      return RegisterResult(
        success: true,
        cliente: cliente,
        requiereConfirmacion: requiereConfirmacion,
      );
    } on PostgrestException catch (e) {
      await _client.auth.signOut();
      if (e.code == '23505') {
        return const RegisterResult(
          success: false,
          errorMessage:
              'Ya existe una cuenta con este DNI o correo. Intenta iniciar sesión.',
        );
      }
      return const RegisterResult(
        success: false,
        errorMessage:
            'No pudimos guardar tu perfil. Inténtalo de nuevo.',
      );
    } on AuthException catch (e) {
      return RegisterResult(
        success: false,
        errorMessage: _mensajeAuthError(e.message),
      );
    } catch (e) {
      return const RegisterResult(
        success: false,
        errorMessage:
            'Ocurrió un error al registrar tu cuenta. Inténtalo más tarde.',
      );
    }
  }

  String _mensajeAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'Ya existe una cuenta con estos datos. Intenta iniciar sesión.';
    }
    if (msg.contains('password')) {
      return 'La contraseña no cumple los requisitos de seguridad.';
    }
    return 'No pudimos completar el registro. Revisa tus datos e inténtalo de nuevo.';
  }

  Future<ClienteModel?> _getPerfilCliente(String authUserId, String dni) async {
    try {
      final data = await _client
          .from('clientes')
          .select()
          .or('auth_user_id.eq.$authUserId,documento.eq.$dni')
          .maybeSingle();
      if (data == null) return null;
      return ClienteModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<ClienteModel?> recuperarSesion() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      final data = await _client
          .from('clientes')
          .select()
          .eq('auth_user_id', user.id)
          .maybeSingle();
      if (data == null) return null;
      return ClienteModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  bool get tieneSession => _client.auth.currentUser != null;
}
