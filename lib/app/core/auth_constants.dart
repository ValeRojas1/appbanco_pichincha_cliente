class AuthConstants {
  static const String emailDomain = '@clientes.pichincha.pe';
  static const int maxIntentos = 5;
  static const int sessionTimeoutHours = 8;
  static const String rolCliente = 'cliente';
  static String emailFromDni(String dni) => '$dni$emailDomain';
}
