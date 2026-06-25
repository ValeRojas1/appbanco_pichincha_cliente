class SolicitudDocumentoModel {
  final String id;
  final String solicitudId;
  final String tipoDocumento;
  final bool obligatorio;
  final String storagePath;
  final String estado;

  SolicitudDocumentoModel({
    required this.id,
    required this.solicitudId,
    required this.tipoDocumento,
    required this.obligatorio,
    required this.storagePath,
    required this.estado,
  });

  bool get estaListo => estado == 'listo';
  bool get estaPendiente => estado == 'pendiente';

  String get tipoLabel {
    switch (tipoDocumento) {
      case 'dni_anverso':
        return 'DNI (Anverso)';
      case 'dni_reverso':
        return 'DNI (Reverso)';
      case 'foto_negocio':
        return 'Foto del Negocio';
      case 'foto_asesor_cliente':
        return 'Foto con Asesor';
      case 'recibo_servicios':
        return 'Recibo de Servicios';
      default:
        return tipoDocumento.replaceAll('_', ' ').toUpperCase();
    }
  }

  factory SolicitudDocumentoModel.fromJson(Map<String, dynamic> json) {
    return SolicitudDocumentoModel(
      id: json['id'] ?? '',
      solicitudId: json['solicitudid'] ?? '',
      tipoDocumento: json['tipodocumento'] ?? '',
      obligatorio: json['obligatorio'] ?? false,
      storagePath: json['storagepath'] ?? '',
      estado: json['estado'] ?? 'pendiente',
    );
  }
}
