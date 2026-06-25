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

  Future<List<TransaccionModel>> getTransaccionesPorCuenta(String cuentaid) async {
    try {
      final response = await _client
          .from('transacciones')
          .select()
          .eq('cuentaid', cuentaid)
          .order('fecha', ascending: false);
      return (response as List).map((e) => TransaccionModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> actualizarSaldo(String cuentaid, double nuevoSaldo) async {
    try {
      await _client
          .from('cuentas')
          .update({'saldo': nuevoSaldo})
          .eq('id', cuentaid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registrarTransaccion(Map<String, dynamic> transaccionData) async {
    try {
      await _client
          .from('transacciones')
          .insert(transaccionData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> buscarNombrePorTelefono(String telefono) async {
    try {
      // Intentar buscar en la tabla clientes
      final resCliente = await _client
          .from('clientes')
          .select('nombres, apellidos')
          .eq('telefono', telefono)
          .maybeSingle();
      if (resCliente != null) {
        return "${resCliente['nombres']} ${resCliente['apellidos']}";
      }

      // Intentar buscar en la tabla usuariosmock
      final resUsuario = await _client
          .from('usuariosmock')
          .select('nombre, apellido')
          .eq('telefono', telefono)
          .maybeSingle();
      if (resUsuario != null) {
        return "${resUsuario['nombre']} ${resUsuario['apellido']}";
      }
    } catch (_) {}
    return null;
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
