import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClienteCacheDb {
  static const String _keyPerfil = 'cache_cliente_perfil';
  static const String _keyCreditos = 'cache_cliente_creditos';
  static const String _keyAlertas = 'cache_cliente_alertas';

  static Future<void> guardarPerfil(Map<String, dynamic> perfil) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPerfil, jsonEncode(perfil));
  }

  static Future<Map<String, dynamic>?> obtenerPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyPerfil);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> guardarCreditos(List<Map<String, dynamic>> creditos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCreditos, jsonEncode(creditos));
  }

  static Future<List<Map<String, dynamic>>> obtenerCreditos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCreditos);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> guardarAlertas(List<Map<String, dynamic>> alertas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAlertas, jsonEncode(alertas));
  }

  static Future<List<Map<String, dynamic>>> obtenerAlertas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyAlertas);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> limpiarCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPerfil);
    await prefs.remove(_keyCreditos);
    await prefs.remove(_keyAlertas);
  }
}
