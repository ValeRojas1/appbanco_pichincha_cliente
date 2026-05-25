class CuentaAhorroModel {
  final String ahorroid;
  final String userid;
  final double saldo;
  final double? metaahorro;
  final double? tasainteres;
  final DateTime? fechaapertura;

  CuentaAhorroModel({
    required this.ahorroid,
    required this.userid,
    required this.saldo,
    this.metaahorro,
    this.tasainteres,
    this.fechaapertura,
  });

  factory CuentaAhorroModel.fromJson(Map<String, dynamic> json) {
    return CuentaAhorroModel(
      ahorroid: json['id'] ?? '',
      userid: json['userid'] ?? '',
      saldo: (json['saldo'] ?? 0).toDouble(),
      metaahorro: (json['metaahorro'] as num?)?.toDouble(),
      tasainteres: (json['tasainteres'] as num?)?.toDouble(),
      fechaapertura: json['fechaapertura'] != null ? DateTime.tryParse(json['fechaapertura']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': ahorroid,
      'userid': userid,
      'saldo': saldo,
      'metaahorro': metaahorro,
      'tasainteres': tasainteres,
      'fechaapertura': fechaapertura?.toIso8601String(),
    };
  }
}
