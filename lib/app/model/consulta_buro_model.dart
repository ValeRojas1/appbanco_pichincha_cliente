class ConsultaBuroModel {
  final String id;
  final String documento;
  final String? clasificacionSbs;
  final double deudaTotal;
  final int diasMoraHistorica;
  final bool enListaNegra;
  final DateTime createdat;

  ConsultaBuroModel({
    required this.id,
    required this.documento,
    this.clasificacionSbs,
    required this.deudaTotal,
    required this.diasMoraHistorica,
    required this.enListaNegra,
    required this.createdat,
  });

  factory ConsultaBuroModel.fromJson(Map<String, dynamic> json) {
    return ConsultaBuroModel(
      id: json['id'] ?? '',
      documento: json['documento'] ?? '',
      clasificacionSbs: json['clasificacion_sbs'],
      deudaTotal: double.tryParse(json['deuda_total']?.toString() ?? '') ?? 0.0,
      diasMoraHistorica: json['dias_mora_historica'] ?? 0,
      enListaNegra: json['enlistanegra'] ?? false,
      createdat: DateTime.tryParse(json['createdat'] ?? '') ?? DateTime.now(),
    );
  }
}
