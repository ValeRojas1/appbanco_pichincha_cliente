class CuentaModel {
  final String numeroCuenta;
  final String tipoCuenta; // 'ahorros' | 'credito'
  final double saldo;
  final String moneda;
  final double? montoPendiente; // solo para crédito

  CuentaModel({
    required this.numeroCuenta,
    required this.tipoCuenta,
    required this.saldo,
    required this.moneda,
    this.montoPendiente,
  });
}