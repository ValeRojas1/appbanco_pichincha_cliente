import 'package:appbanco_pichincha_cliente/app/core/estado_solicitud.dart';

class SolicitudCreditoModel {
  final String id;
  final String estado;
  final String nombres;
  final String apellidos;
  final String dni;
  final double monto;
  final int plazoMeses;
  final double tea;
  final double cuotaMensual;
  final String? tipoGarantia;
  final String? tipoNegocio;
  final String? nombreNegocio;
  final String? direccionNegocio;
  final double? latitudNegocio;
  final double? longitudNegocio;
  final double? ingresosEstimados;
  final double? gastosEstimados;
  final int? antiguedadMeses;
  final String? numeroExpediente;
  final String? analistaAsignado;
  final DateTime? fechaEnvio;
  final DateTime? fechaAprobacion;
  final DateTime? fechaDesembolso;
  final String? motivoRechazo;
  final DateTime createdat;

  SolicitudCreditoModel({
    required this.id,
    required this.estado,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.monto,
    required this.plazoMeses,
    required this.tea,
    required this.cuotaMensual,
    this.tipoGarantia,
    this.tipoNegocio,
    this.nombreNegocio,
    this.direccionNegocio,
    this.latitudNegocio,
    this.longitudNegocio,
    this.ingresosEstimados,
    this.gastosEstimados,
    this.antiguedadMeses,
    this.numeroExpediente,
    this.analistaAsignado,
    this.fechaEnvio,
    this.fechaAprobacion,
    this.fechaDesembolso,
    this.motivoRechazo,
    required this.createdat,
  });

  EstadoSolicitud get estadoEnum => EstadoSolicitud.fromString(estado);
  String get nombreCompleto => '$nombres $apellidos';

  String get mensajeEstado =>
      estadoEnum.mensajeParaCliente(fechaDesembolso: fechaDesembolso);

  static DateTime? _parseFecha(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  factory SolicitudCreditoModel.fromJson(Map<String, dynamic> json) {
    return SolicitudCreditoModel(
      id: json['id'] ?? '',
      estado: json['estado'] ?? 'enviada',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      dni: json['dni'] ?? '',
      monto: double.tryParse(json['monto']?.toString() ?? '') ?? 0.0,
      plazoMeses: json['plazomeses'] ?? 0,
      tea: double.tryParse(json['tea']?.toString() ?? '') ?? 0.0,
      cuotaMensual: double.tryParse(json['cuotamensual']?.toString() ?? '') ?? 0.0,
      tipoGarantia: json['tipogarantia']?.toString(),
      tipoNegocio: json['tiponegocio']?.toString(),
      nombreNegocio: json['nombrenegocio']?.toString(),
      direccionNegocio: json['direccionnegocio']?.toString(),
      latitudNegocio:
          double.tryParse(json['latitudnegocio']?.toString() ?? ''),
      longitudNegocio:
          double.tryParse(json['longitudnegocio']?.toString() ?? ''),
      ingresosEstimados:
          double.tryParse(json['ingresosestimados']?.toString() ?? ''),
      gastosEstimados:
          double.tryParse(json['gastosestimados']?.toString() ?? ''),
      antiguedadMeses: json['antiguedadmeses'] is int
          ? json['antiguedadmeses'] as int
          : int.tryParse(json['antiguedadmeses']?.toString() ?? ''),
      numeroExpediente: json['numeroexpediente'],
      analistaAsignado: json['analistaasignado'],
      fechaEnvio: _parseFecha(json['fechaenvio'] ?? json['fechaeenvio']),
      fechaAprobacion: json['fechaaprobacion'] != null
          ? DateTime.tryParse(json['fechaaprobacion'])
          : null,
      fechaDesembolso: json['fechadesembolso'] != null
          ? DateTime.tryParse(json['fechadesembolso'])
          : null,
      motivoRechazo: json['motivorechazo'],
      createdat: DateTime.tryParse(json['createdat'] ?? '') ?? DateTime.now(),
    );
  }
}
