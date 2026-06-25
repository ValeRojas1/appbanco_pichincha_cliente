class CreditoPreaprobadoModel {
  final String id;
  final double montoPreaprobado;
  final int plazoMeses;
  final double tasaMensual;
  final double? cuotaEstimada;
  final double tea;
  final String estado;
  final String vigenteHasta;
  final bool vigente;
  final String? clienteIdFicha;

  CreditoPreaprobadoModel({
    required this.id,
    required this.montoPreaprobado,
    required this.plazoMeses,
    required this.tasaMensual,
    this.cuotaEstimada,
    required this.tea,
    required this.estado,
    required this.vigenteHasta,
    required this.vigente,
    this.clienteIdFicha,
  });

  factory CreditoPreaprobadoModel.fromJson(Map<String, dynamic> json) {
    return CreditoPreaprobadoModel(
      id: json['id'] ?? '',
      montoPreaprobado: double.tryParse(json['montopreaprobado']?.toString() ?? '') ?? 0.0,
      plazoMeses: json['plazomeses'] ?? 12,
      tasaMensual: double.tryParse(json['tasamensual']?.toString() ?? '') ?? 0.0,
      cuotaEstimada: json['cuotaestimada'] != null
          ? double.tryParse(json['cuotaestimada'].toString())
          : null,
      tea: double.tryParse(json['tea']?.toString() ?? '') ?? 0.0,
      estado: json['estado'] ?? 'pre-aprobado',
      vigenteHasta: json['vigentehasta'] ?? '',
      vigente: json['vigente'] ?? true,
      clienteIdFicha: json['clienteid_ficha'],
    );
  }
}
