class CampanaActivaModel {
  final String id;
  final String tipoCampana;
  final String nombreCliente;
  final double montoOferta;
  final String fechaVencimiento;
  final bool activa;
  final String? clienteId;

  CampanaActivaModel({
    required this.id,
    required this.tipoCampana,
    required this.nombreCliente,
    required this.montoOferta,
    required this.fechaVencimiento,
    required this.activa,
    this.clienteId,
  });

  factory CampanaActivaModel.fromJson(Map<String, dynamic> json) {
    return CampanaActivaModel(
      id: json['id'] ?? '',
      tipoCampana: json['tipocampana'] ?? '',
      nombreCliente: json['nombrecliente'] ?? '',
      montoOferta: double.tryParse(json['montooferta']?.toString() ?? '') ?? 0.0,
      fechaVencimiento: json['fechavencimiento'] ?? '',
      activa: json['activa'] ?? true,
      clienteId: json['clienteid'],
    );
  }
}
