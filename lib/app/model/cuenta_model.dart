class CuentaModel {
  final String cuentaid;
  final String userid;
  final String tipocuenta;
  final String moneda;
  final double saldo;
  final String? numerocuenta;
  final DateTime? createdat;

  CuentaModel({
    required this.cuentaid,
    required this.userid,
    required this.tipocuenta,
    required this.moneda,
    required this.saldo,
    this.numerocuenta,
    this.createdat,
  });

  factory CuentaModel.fromJson(Map<String, dynamic> json) {
    return CuentaModel(
      cuentaid: json['id'] ?? '',
      userid: json['userid'] ?? '',
      tipocuenta: json['tipo'] ?? '',
      moneda: json['moneda'] ?? 'PEN',
      saldo: (json['saldo'] ?? 0).toDouble(),
      numerocuenta: json['numerocuenta'],
      createdat: json['createdat'] != null ? DateTime.tryParse(json['createdat']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': cuentaid,
      'userid': userid,
      'tipo': tipocuenta,
      'moneda': moneda,
      'saldo': saldo,
      'numerocuenta': numerocuenta,
      'createdat': createdat?.toIso8601String(),
    };
  }
}
