class PreEvaluacionResultadoModel {
  final String resultado;
  final String mensaje;
  final double monto;
  final String dni;
  final bool evaluacionLocal;

  PreEvaluacionResultadoModel({
    required this.resultado,
    required this.mensaje,
    required this.monto,
    required this.dni,
    this.evaluacionLocal = false,
  });

  String get _normalizado => resultado.trim().toUpperCase();

  /// APTO / aprobado — elegible para solicitar crédito.
  bool get esAprobado =>
      _normalizado == 'APTO' || _normalizado == 'APROBADO';

  /// REVISAR / observado — puede solicitar; operador revisará en visita.
  bool get esObservado =>
      _normalizado == 'REVISAR' ||
      _normalizado == 'OBSERVADO' ||
      _normalizado == 'EN REVISION';

  /// NO PROCEDE / rechazado — no elegible por ahora.
  bool get esRechazado =>
      _normalizado == 'NO PROCEDE' ||
      _normalizado == 'RECHAZADO' ||
      _normalizado == 'NO_PROCEDE';

  /// Puede registrar solicitud en bandeja de operadores.
  bool get puedeSolicitarCredito => esAprobado || esObservado;

  factory PreEvaluacionResultadoModel.fromJson(Map<String, dynamic> json) {
    return PreEvaluacionResultadoModel(
      resultado: json['resultado']?.toString() ?? 'REVISAR',
      mensaje: json['mensaje']?.toString() ?? '',
      monto: double.tryParse(json['monto']?.toString() ?? '') ?? 0.0,
      dni: json['dni']?.toString() ?? '',
      evaluacionLocal: json['evaluacion_local'] == true,
    );
  }
}
