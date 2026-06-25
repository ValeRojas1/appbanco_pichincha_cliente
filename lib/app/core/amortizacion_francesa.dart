import 'dart:math';

class AmortizacionFrancesa {
  /// Prima mensual referencial de seguro de desgravamen (0.1% del capital).
  static double primaDesgravamenMensual(double monto) => monto * 0.001;

  /// Calcula la cuota mensual usando amortización francesa
  /// [monto] capital
  /// [tea] tasa efectiva anual en porcentaje (ej: 28.5)
  /// [plazomeses] número de cuotas
  static double calcularCuota(
    double monto,
    double tea,
    int plazomeses, {
    bool incluyeSeguroDesgravamen = false,
  }) {
    if (plazomeses <= 0 || monto <= 0) return 0;
    // Convertir TEA a TEM
    final double tem = pow(1 + tea / 100, 1 / 12).toDouble() - 1;
    if (tem == 0) return monto / plazomeses;
    final double cuotaCredito = monto *
        tem *
        pow(1 + tem, plazomeses).toDouble() /
        (pow(1 + tem, plazomeses).toDouble() - 1);
    if (!incluyeSeguroDesgravamen) return cuotaCredito;
    return cuotaCredito + primaDesgravamenMensual(monto);
  }

  /// Genera tabla de amortización completa
  static List<Map<String, dynamic>> generarTabla(
      double monto, double tea, int plazomeses) {
    final List<Map<String, dynamic>> tabla = [];
    final double tem = pow(1 + tea / 100, 1 / 12).toDouble() - 1;
    double saldo = monto;
    final double cuota = calcularCuota(monto, tea, plazomeses);
    for (int i = 1; i <= plazomeses; i++) {
      final double interes = saldo * tem;
      final double capital = cuota - interes;
      saldo = saldo - capital;
      tabla.add({
        'cuota': i,
        'cuotaMensual': cuota,
        'capital': capital,
        'interes': interes,
        'saldoPendiente': saldo < 0 ? 0.0 : saldo,
      });
    }
    return tabla;
  }

  /// Total de intereses a pagar
  static double totalIntereses(double monto, double tea, int plazomeses) {
    final double cuota = calcularCuota(monto, tea, plazomeses);
    return (cuota * plazomeses) - monto;
  }
}
