class PagoModel {
  final String pagoid;
  final String userid;
  final String servicio;
  final String numerocontrato;
  final double monto;
  final String estado;
  final DateTime? fecha;

  PagoModel({
    required this.pagoid,
    required this.userid,
    required this.servicio,
    required this.numerocontrato,
    required this.monto,
    required this.estado,
    this.fecha,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      pagoid: json['id'] ?? '',
      userid: json['userid'] ?? '',
      servicio: json['servicio'] ?? '',
      numerocontrato: json['numerocontrato'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      estado: json['estado'] ?? '',
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': pagoid,
      'userid': userid,
      'servicio': servicio,
      'numerocontrato': numerocontrato,
      'monto': monto,
      'estado': estado,
      'fecha': fecha?.toIso8601String(),
    };
  }
}
