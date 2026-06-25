import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/cliente_model.dart';
import '../model/solicitud_credito_model.dart';

class CrearSolicitudClienteResult {
  final bool ok;
  final String? solicitudId;
  final String? numeroExpediente;
  final String? estado;
  final String? error;
  final bool solicitudActivaExistente;

  const CrearSolicitudClienteResult({
    required this.ok,
    this.solicitudId,
    this.numeroExpediente,
    this.estado,
    this.error,
    this.solicitudActivaExistente = false,
  });
}

class SolicitudCreditoService {
  final SupabaseClient _client = Supabase.instance.client;

  static const _estadosActivos = [
    'pendiente_operador',
    'en_atencion',
    'documentos_pendientes',
    'completa',
    'enviada',
    'en_comite',
  ];

  Future<List<SolicitudCreditoModel>> getSolicitudes(String dni) async {
    try {
      final data = await _client
          .from('solicitudescredito')
          .select()
          .eq('dni', dni)
          .order('createdat', ascending: false);
      return (data as List)
          .map((e) => SolicitudCreditoModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Genera un número de expediente legible y único para el cliente.
  String _generarNumeroExpediente() {
    final now = DateTime.now();
    final fecha = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final serie = (now.millisecondsSinceEpoch % 1000000)
        .toString()
        .padLeft(6, '0');
    return 'EXP-$fecha-$serie';
  }

  /// Registra la solicitud de crédito desde la app del cliente.
  /// La deja en `pendiente_operador` para que un operador la tome en ventas.
  Future<CrearSolicitudClienteResult> crearSolicitud({
    required ClienteModel cliente,
    required double monto,
    required double ingresos,
    required String tipoNegocio,
    required String nombreNegocio,
    required String direccionNegocio,
    double? latitudNegocio,
    double? longitudNegocio,
    required String destino,
    required int plazoMeses,
    required double tea,
    required String garantia,
    required double cuotaMensual,
    required double gastosEstimados,
    required int antiguedadMeses,
    bool incluyeSeguroDesgravamen = true,
  }) async {
    try {
      final activa = await _client
          .from('solicitudescredito')
          .select('id, estado, numeroexpediente')
          .eq('dni', cliente.documento)
          .inFilter('estado', _estadosActivos)
          .order('createdat', ascending: false)
          .limit(1)
          .maybeSingle();

      if (activa != null) {
        return CrearSolicitudClienteResult(
          ok: true,
          solicitudId: activa['id']?.toString(),
          numeroExpediente: activa['numeroexpediente']?.toString(),
          estado: activa['estado']?.toString(),
          solicitudActivaExistente: true,
        );
      }

      final row = await _client
          .from('solicitudescredito')
          .insert({
            'estado': 'pendiente_operador',
            'origen': 'app_cliente',
            'dni': cliente.documento,
            'nombres': cliente.nombres,
            'apellidos': cliente.apellidos,
            'telefono': cliente.telefono ?? '',
            'email': cliente.correo ?? '',
            'monto': monto,
            'tiponegocio': tipoNegocio,
            'nombrenegocio': nombreNegocio,
            'direccionnegocio': direccionNegocio,
            'latitudnegocio': ?latitudNegocio,
            'longitudnegocio': ?longitudNegocio,
            'destinocredito': destino,
            'ingresosestimados': ingresos,
            'gastosestimados': gastosEstimados,
            'plazomeses': plazoMeses,
            'moneda': 'PEN',
            'tipocuota': 'fija',
            'tipogarantia': garantia,
            'tea': tea,
            'cuotamensual': cuotaMensual,
            'incluyesegurodesgravamen': incluyeSeguroDesgravamen,
            'codigociiu': '4711',
            'antiguedadmeses': antiguedadMeses,
          })
          .select('id, numeroexpediente, estado')
          .single();

      return CrearSolicitudClienteResult(
        ok: true,
        solicitudId: row['id']?.toString(),
        numeroExpediente: row['numeroexpediente']?.toString(),
        estado: row['estado']?.toString() ?? 'pendiente_operador',
      );
    } catch (e) {
      return CrearSolicitudClienteResult(
        ok: false,
        error: 'No se pudo registrar la solicitud: $e',
      );
    }
  }

  RealtimeChannel suscribirCambios(
    String dni,
    void Function(SolicitudCreditoModel) onCambio,
  ) {
    void onRecord(Map<String, dynamic> record) {
      if (record.isNotEmpty) {
        onCambio(SolicitudCreditoModel.fromJson(record));
      }
    }

    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'dni',
      value: dni,
    );

    return _client
        .channel('solicitudes_$dni')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'solicitudescredito',
          filter: filter,
          callback: (payload) => onRecord(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'solicitudescredito',
          filter: filter,
          callback: (payload) => onRecord(payload.newRecord),
        )
        .subscribe();
  }

  Future<void> cancelarSuscripcion(RealtimeChannel canal) async {
    await _client.removeChannel(canal);
  }
}
