class PagoMensualModel {
  final String id;
  final String clienteId;
  final String periodo;
  final String estado;
  final double montoPagado;
  final int diasMora;

  PagoMensualModel({
    required this.id,
    required this.clienteId,
    required this.periodo,
    required this.estado,
    required this.montoPagado,
    required this.diasMora,
  });

  bool get estaPuntual => estado == 'puntual';
  bool get enMora => estado == 'mora';

  factory PagoMensualModel.fromJson(Map<String, dynamic> json) {
    return PagoMensualModel(
      id: json['id'] ?? '',
      clienteId: json['clienteid'] ?? '',
      periodo: json['periodo'] ?? '',
      estado: json['estado'] ?? 'sin_cuota',
      montoPagado: double.tryParse(json['montopagado']?.toString() ?? '') ?? 0.0,
      diasMora: json['diasmora'] ?? 0,
    );
  }
}
