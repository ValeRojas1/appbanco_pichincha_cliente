class AuthValidators {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );
  static final _nombreRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
  static final _soloDigitos = RegExp(r'^\d+$');

  static String? validarDni(String? value) {
    final dni = value?.trim() ?? '';
    if (dni.isEmpty) return 'Ingresa tu número de DNI';
    if (!_soloDigitos.hasMatch(dni)) return 'El DNI solo debe contener números';
    if (dni.length != 8) return 'El DNI debe tener exactamente 8 dígitos';
    return null;
  }

  static String? validarCorreo(String? value) {
    final correo = value?.trim().toLowerCase() ?? '';
    if (correo.isEmpty) return 'Ingresa tu correo electrónico';
    if (correo.length > 100) return 'El correo es demasiado largo';
    if (!_emailRegex.hasMatch(correo)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? validarNombres(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Ingresa tus nombres';
    if (texto.length < 2) return 'Mínimo 2 caracteres';
    if (texto.length > 60) return 'Máximo 60 caracteres';
    if (!_nombreRegex.hasMatch(texto)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  static String? validarApellidos(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Ingresa tus apellidos';
    if (texto.length < 2) return 'Mínimo 2 caracteres';
    if (texto.length > 60) return 'Máximo 60 caracteres';
    if (!_nombreRegex.hasMatch(texto)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  static String? validarTelefono(String? value) {
    final telefono = value?.trim() ?? '';
    if (telefono.isEmpty) return 'Ingresa tu número de celular';
    if (!_soloDigitos.hasMatch(telefono)) {
      return 'El teléfono solo debe contener números';
    }
    if (telefono.length != 9) return 'El celular debe tener 9 dígitos';
    if (!telefono.startsWith('9')) {
      return 'El celular peruano debe comenzar con 9';
    }
    return null;
  }

  static String? validarPassword(String? value) {
    final pass = value ?? '';
    if (pass.isEmpty) return 'Ingresa una contraseña';
    if (pass.length < 6) return 'Mínimo 6 caracteres';
    if (pass.length > 20) return 'Máximo 20 caracteres';
    if (!_soloDigitos.hasMatch(pass)) {
      return 'La contraseña solo debe contener números';
    }
    if (RegExp(r'^(\d)\1+$').hasMatch(pass)) {
      return 'No uses el mismo dígito repetido';
    }
    return null;
  }

  static String? validarConfirmarPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) return 'Las contraseñas no coinciden';
    return null;
  }
}
