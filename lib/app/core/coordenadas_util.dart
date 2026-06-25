class CoordenadasUtil {
  static bool esLatitudValida(double? lat) {
    if (lat == null) return false;
    return lat >= -90 && lat <= 90;
  }

  static bool esLongitudValida(double? lng) {
    if (lng == null) return false;
    return lng >= -180 && lng <= 180;
  }

  static bool parValido(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return esLatitudValida(lat) && esLongitudValida(lng);
  }

  static String? validarLatitudTexto(String? texto) {
    if (texto == null || texto.trim().isEmpty) return null;
    final v = double.tryParse(texto.trim().replaceAll(',', '.'));
    if (v == null) return 'Ingresa un número válido';
    if (!esLatitudValida(v)) return 'Latitud entre -90 y 90';
    return null;
  }

  static String? validarLongitudTexto(String? texto) {
    if (texto == null || texto.trim().isEmpty) return null;
    final v = double.tryParse(texto.trim().replaceAll(',', '.'));
    if (v == null) return 'Ingresa un número válido';
    if (!esLongitudValida(v)) return 'Longitud entre -180 y 180';
    return null;
  }

  static String formatearCoordenadas(double lat, double lng) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }
}
