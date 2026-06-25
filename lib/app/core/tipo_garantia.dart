/// Tipos de garantía válidos para `tipogarantia` en `solicitudescredito`.
class TipoGarantia {
  TipoGarantia._();

  static const sinGarantia = 'sin_garantia';
  static const personal = 'personal';
  static const solidaria = 'solidaria';
  static const hipotecaria = 'hipotecaria';
  static const prendaria = 'prendaria';
  static const aval = 'aval';

  static const opcionesCliente = <String, String>{
    sinGarantia: 'Sin garantía',
    personal: 'Garantía personal',
    solidaria: 'Garantía solidaria',
    hipotecaria: 'Garantía hipotecaria',
    prendaria: 'Garantía prendaria',
    aval: 'Con aval',
  };

  static String etiqueta(String? codigo) {
    if (codigo == null || codigo.isEmpty) return 'Sin especificar';
    return opcionesCliente[codigo] ?? codigo;
  }
}
