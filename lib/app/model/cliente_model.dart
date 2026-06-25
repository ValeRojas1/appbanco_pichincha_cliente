class ClienteModel {
  final String id;
  final String documento;
  final String nombres;
  final String apellidos;
  final String? telefono;
  final String? correo;
  final String? tipoNegocio;
  final String clasificacionSbs;
  final double deudaTotal;
  final int cuentasVigentes;
  final int cuentasEnMora;
  final int diasMayorMora;
  final String? fechaUltimoPago;
  final String? authUserId;

  ClienteModel({
    required this.id,
    required this.documento,
    required this.nombres,
    required this.apellidos,
    this.telefono,
    this.correo,
    this.tipoNegocio,
    required this.clasificacionSbs,
    required this.deudaTotal,
    required this.cuentasVigentes,
    required this.cuentasEnMora,
    required this.diasMayorMora,
    this.fechaUltimoPago,
    this.authUserId,
  });

  String get nombreCompleto => '$nombres $apellidos';
  String get primerNombre => nombres.split(' ').first;

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] ?? '',
      documento: json['documento'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      telefono: json['telefono'],
      correo: json['correo'],
      tipoNegocio: json['tiponegocio'],
      clasificacionSbs: json['clasificacionsbs'] ?? 'Normal',
      deudaTotal: double.tryParse(json['deudatotal']?.toString() ?? '') ?? 0.0,
      cuentasVigentes: json['cuentasvigentes'] ?? 0,
      cuentasEnMora: json['cuentasenmora'] ?? 0,
      diasMayorMora: json['diasmayormora'] ?? 0,
      fechaUltimoPago: json['fechaultimopago'],
      authUserId: json['auth_user_id'],
    );
  }
}
