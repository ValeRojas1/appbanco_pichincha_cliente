class CreditoModel {
  final String id;
  final String clienteId;
  final String numeroCredito;
  final double monto;
  final int plazoMeses;
  final double tea;
  final String estado;
  final String fechaDesembolso;
  final double saldoPendiente;

  CreditoModel({
    required this.id,
    required this.clienteId,
    required this.numeroCredito,
    required this.monto,
    required this.plazoMeses,
    required this.tea,
    required this.estado,
    required this.fechaDesembolso,
    required this.saldoPendiente,
  });

  bool get estaVigente => estado == 'vigente';
  bool get estaMoroso => estado == 'moroso';

  String get estadoLabel {
    switch (estado.toLowerCase()) {
      case 'vigente':
        return 'Al día';
      case 'moroso':
        return 'Con atraso';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  factory CreditoModel.fromJson(Map<String, dynamic> json) {
    return CreditoModel(
      id: json['id'] ?? '',
      clienteId: json['clienteid'] ?? '',
      numeroCredito: json['numerocredito'] ?? '',
      monto: double.tryParse(json['monto']?.toString() ?? '') ?? 0.0,
      plazoMeses: json['plazomeses'] ?? 0,
      tea: double.tryParse(json['tea']?.toString() ?? '') ?? 0.0,
      estado: json['estado'] ?? 'vigente',
      fechaDesembolso: json['fechadesembolso'] ?? '',
      saldoPendiente: double.tryParse(json['saldopendiente']?.toString() ?? '') ?? 0.0,
    );
  }
}
