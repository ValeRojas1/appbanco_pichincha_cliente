class TransaccionModel {
  final String transaccionid;
  final String cuentaid;
  final String tipotransaccion;
  final double monto;
  final String descripcion;
  final DateTime? fecha;

  TransaccionModel({
    required this.transaccionid,
    required this.cuentaid,
    required this.tipotransaccion,
    required this.monto,
    required this.descripcion,
    this.fecha,
  });

  factory TransaccionModel.fromJson(Map<String, dynamic> json) {
    return TransaccionModel(
      transaccionid: json['id'] ?? '',
      cuentaid: json['cuentaid'] ?? '',
      tipotransaccion: json['tipo'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': transaccionid,
      'cuentaid': cuentaid,
      'tipo': tipotransaccion,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha?.toIso8601String(),
    };
  }
}
