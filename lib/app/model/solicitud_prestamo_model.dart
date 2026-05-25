class SolicitudPrestamoModel {
  final String solicitudid;
  final String userid;
  final double monto;
  final int plazomeses;
  final String estado;
  final String? proposito;
  final double? tasaanual;
  final double? cuotamensual;
  final DateTime? createdat;

  SolicitudPrestamoModel({
    required this.solicitudid,
    required this.userid,
    required this.monto,
    required this.plazomeses,
    required this.estado,
    this.proposito,
    this.tasaanual,
    this.cuotamensual,
    this.createdat,
  });

  factory SolicitudPrestamoModel.fromJson(Map<String, dynamic> json) {
    return SolicitudPrestamoModel(
      solicitudid: json['id'] ?? '',
      userid: json['userid'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      plazomeses: json['plazomeses'] ?? 0,
      estado: json['estado'] ?? '',
      proposito: json['proposito'],
      tasaanual: (json['tasaanual'] as num?)?.toDouble(),
      cuotamensual: (json['cuotamensual'] as num?)?.toDouble(),
      createdat: json['createdat'] != null ? DateTime.tryParse(json['createdat']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': solicitudid,
      'userid': userid,
      'monto': monto,
      'plazomeses': plazomeses,
      'estado': estado,
      'proposito': proposito,
      'tasaanual': tasaanual,
      'cuotamensual': cuotamensual,
      'createdat': createdat?.toIso8601String(),
    };
  }
}
