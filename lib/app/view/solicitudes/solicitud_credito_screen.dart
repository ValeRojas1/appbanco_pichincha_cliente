import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/amortizacion_francesa.dart';
import '../../core/estado_solicitud.dart';
import '../../core/tipo_garantia.dart';
import '../../services/solicitud_credito_service.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/solicitud_credito_viewmodel.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/slider_valor_input.dart';
import '../../ui/widgets/coordenadas_negocio_input.dart';
import '../../core/coordenadas_util.dart';

/// Argumentos opcionales para precargar el formulario (p. ej. desde la
/// pre-evaluación).
class SolicitudCreditoArgs {
  final double? monto;
  final String? destino;
  final double? ingresos;
  final String? tipoNegocio;
  final String? nombreNegocio;
  final String? direccionNegocio;
  final double? latitudNegocio;
  final double? longitudNegocio;
  final int? gastosEstimados;
  final int? antiguedadMeses;

  const SolicitudCreditoArgs({
    this.monto,
    this.destino,
    this.ingresos,
    this.tipoNegocio,
    this.nombreNegocio,
    this.direccionNegocio,
    this.latitudNegocio,
    this.longitudNegocio,
    this.gastosEstimados,
    this.antiguedadMeses,
  });
}

class SolicitudCreditoScreen extends StatefulWidget {
  final SolicitudCreditoArgs? args;
  const SolicitudCreditoScreen({super.key, this.args});

  @override
  State<SolicitudCreditoScreen> createState() => _SolicitudCreditoScreenState();
}

class _SolicitudCreditoScreenState extends State<SolicitudCreditoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _teaCtrl = TextEditingController(text: '28.0');
  final _nombreNegocioCtrl = TextEditingController();
  final _direccionNegocioCtrl = TextEditingController();

  int _plazo = 12;
  double _monto = 0;
  double _tea = 28.0;
  double _ingresos = 0;
  int _gastosEstimados = 1500;
  int _antiguedadMeses = 6;
  String _tipoNegocio = 'Comercio';

  String _garantia = TipoGarantia.sinGarantia;
  double? _latitudNegocio;
  double? _longitudNegocio;

  final List<String> _destinos = [
    'Capital de Trabajo',
    'Activo Fijo',
    'Consumo',
    'Construcción / Vivienda',
  ];
  String _destino = 'Capital de Trabajo';

  bool _incluyeSeguroDesgravamen = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final a = widget.args;
    if (a != null) {
      if (a.monto != null && a.monto! > 0) {
        _monto = a.monto!;
        _montoCtrl.text = a.monto!.toStringAsFixed(0);
      }
      if (a.destino != null && _destinos.contains(a.destino)) {
        _destino = a.destino!;
      }
      if (a.ingresos != null) _ingresos = a.ingresos!;
      if (a.tipoNegocio != null) _tipoNegocio = a.tipoNegocio!;
      if (a.nombreNegocio != null && a.nombreNegocio!.trim().isNotEmpty) {
        _nombreNegocioCtrl.text = a.nombreNegocio!.trim();
      }
      if (a.direccionNegocio != null && a.direccionNegocio!.trim().isNotEmpty) {
        _direccionNegocioCtrl.text = a.direccionNegocio!.trim();
      }
      if (a.gastosEstimados != null && a.gastosEstimados! >= 0) {
        _gastosEstimados = a.gastosEstimados!;
      }
      if (a.antiguedadMeses != null && a.antiguedadMeses! >= 0) {
        _antiguedadMeses = a.antiguedadMeses!;
      }
      if (CoordenadasUtil.parValido(a.latitudNegocio, a.longitudNegocio)) {
        _latitudNegocio = a.latitudNegocio;
        _longitudNegocio = a.longitudNegocio;
      }
    }
    _tea = double.tryParse(_teaCtrl.text) ?? 28.0;
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _teaCtrl.dispose();
    _nombreNegocioCtrl.dispose();
    _direccionNegocioCtrl.dispose();
    super.dispose();
  }

  double get _cuota => AmortizacionFrancesa.calcularCuota(
        _monto,
        _tea,
        _plazo,
        incluyeSeguroDesgravamen: _incluyeSeguroDesgravamen,
      );
  double get _totalIntereses =>
      AmortizacionFrancesa.totalIntereses(_monto, _tea, _plazo);
  double get _totalPagar => _monto + _totalIntereses;

  void _recalcular() {
    setState(() {
      _monto = double.tryParse(_montoCtrl.text.trim()) ?? 0;
      _tea = double.tryParse(_teaCtrl.text.trim()) ?? 0;
    });
  }

  String _etiquetaEstado(String? estadoDb) {
    return EstadoSolicitud.fromString(estadoDb ?? 'pendiente_operador').label;
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_monto <= 0 || _tea <= 0 || _plazo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa monto, plazo y TEA para continuar.'),
          backgroundColor: AppTheme.rojoError,
        ),
      );
      return;
    }

    final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
    if (cliente == null) return;

    setState(() => _enviando = true);

    final service = SolicitudCreditoService();
    final resultado = await service.crearSolicitud(
      cliente: cliente,
      monto: _monto,
      ingresos: _ingresos,
      tipoNegocio: _tipoNegocio,
      nombreNegocio: _nombreNegocioCtrl.text.trim(),
      direccionNegocio: _direccionNegocioCtrl.text.trim(),
      latitudNegocio: _latitudNegocio,
      longitudNegocio: _longitudNegocio,
      gastosEstimados: _gastosEstimados.toDouble(),
      antiguedadMeses: _antiguedadMeses,
      destino: _destino,
      plazoMeses: _plazo,
      tea: _tea,
      garantia: _garantia,
      cuotaMensual: _cuota,
      incluyeSeguroDesgravamen: _incluyeSeguroDesgravamen,
    );

    if (!mounted) return;
    setState(() => _enviando = false);

    if (!resultado.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.error ?? 'No se pudo registrar la solicitud'),
          backgroundColor: AppTheme.rojoError,
        ),
      );
      return;
    }

    await _mostrarConfirmacion(cliente.documento, resultado);
  }

  Future<void> _mostrarConfirmacion(
    String dni,
    CrearSolicitudClienteResult resultado,
  ) async {
    final navigator = Navigator.of(context);
    final solicitudVm =
        Provider.of<SolicitudCreditoViewModel>(context, listen: false);

    final yaExistia = resultado.solicitudActivaExistente;
    final expediente = resultado.numeroExpediente;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              yaExistia ? Icons.info_outline : Icons.check_circle,
              color: yaExistia ? AppTheme.navy : AppTheme.verdeSaldo,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                yaExistia ? 'Ya tienes una solicitud' : '¡Solicitud registrada!',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              yaExistia
                  ? 'Tienes una solicitud activa en curso. Te mostramos sus datos.'
                  : 'Tu solicitud quedó en la bandeja de operadores. Un asesor te visitará pronto.',
              style: const TextStyle(fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.navy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.navy.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('N° de Expediente',
                      style: TextStyle(fontSize: 12, color: AppTheme.grisMedio)),
                  const SizedBox(height: 4),
                  Text(
                    expediente ?? 'Se asignará cuando un operador atienda tu solicitud',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.hourglass_top, size: 15, color: AppTheme.grisMedio),
                      const SizedBox(width: 6),
                      Text(
                        'Estado: ${_etiquetaEstado(resultado.estado)}',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.navy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await solicitudVm.cargarSolicitudes(dni);
              navigator.pushNamedAndRemoveUntil(
                '/solicitudes',
                (route) => false,
              );
            },
            child: const Text(
              'Ver mis solicitudes',
              style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Solicitud de Crédito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configura tu crédito',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navy),
              ),
              const SizedBox(height: 6),
              const Text(
                'Define el monto, plazo, tasa, garantía y destino. Verás la cuota estimada en tiempo real antes de enviar.',
                style: TextStyle(fontSize: 13, color: AppTheme.grisMedio),
              ),
              const SizedBox(height: 20),
              _buildNegocioCard(),
              const SizedBox(height: 20),
              _buildFormCard(),
              const SizedBox(height: 20),
              _buildCuotaCard(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _confirmar,
                  child: _enviando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.navy),
                        )
                      : const Text('Confirmar y enviar solicitud'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Al confirmar, tu solicitud quedará en espera de asignación de un operador.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.grisMedio),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNegocioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos de tu negocio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Indica el nombre, dirección y situación económica de tu negocio. Un asesor usará estos datos para visitarte.',
            style: TextStyle(fontSize: 13, color: AppTheme.grisMedio),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nombreNegocioCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre del negocio',
              prefixIcon: Icon(Icons.store_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ingresa el nombre de tu negocio';
              }
              if (v.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _direccionNegocioCtrl,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Dirección del negocio',
              hintText: 'Ej: Av. Principal 123, distrito, referencia',
              prefixIcon: Icon(Icons.location_on_outlined),
              alignLabelWithHint: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ingresa la dirección de tu negocio';
              }
              if (v.trim().length < 10) {
                return 'Describe la dirección con más detalle';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          CoordenadasNegocioInput(
            latitud: _latitudNegocio,
            longitud: _longitudNegocio,
            onLatitudChanged: (v) => setState(() => _latitudNegocio = v),
            onLongitudChanged: (v) => setState(() => _longitudNegocio = v),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          SliderValorInput(
            label: 'Gastos mensuales estimados',
            manualLabel: 'Gastos mensuales (S/)',
            icon: Icons.receipt_long_outlined,
            min: 0,
            max: 50000,
            divisions: 100,
            value: _gastosEstimados,
            valuePrefix: 'S/ ',
            minLabel: 'S/ 0',
            maxLabel: 'S/ 50 000',
            onChanged: (v) => setState(() => _gastosEstimados = v),
            validator: (v) {
              if (v <= 0) {
                return 'Indica tus gastos mensuales estimados';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SliderValorInput(
            label: 'Antigüedad del negocio',
            manualLabel: 'Meses de antigüedad',
            icon: Icons.calendar_month_outlined,
            min: 1,
            max: 240,
            divisions: 239,
            value: _antiguedadMeses,
            suffix: 'meses',
            minLabel: '1 mes',
            maxLabel: '240 meses',
            onChanged: (v) => setState(() => _antiguedadMeses = v),
            validator: (v) {
              if (v < 1) {
                return 'Indica al menos 1 mes de antigüedad';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monto
          TextFormField(
            controller: _montoCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: const InputDecoration(
              labelText: 'Monto del crédito (S/)',
              prefixIcon: Icon(Icons.monetization_on_outlined),
            ),
            onChanged: (_) => _recalcular(),
            validator: (v) {
              final value = double.tryParse((v ?? '').trim());
              if (value == null || value <= 0) {
                return 'Ingresa un monto válido, por ejemplo: 10000';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          // Plazo
          Text('Plazo: $_plazo meses',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.navy)),
          Slider(
            value: _plazo.toDouble(),
            min: 6,
            max: 60,
            divisions: 54,
            activeColor: AppTheme.navy,
            inactiveColor: AppTheme.navy.withValues(alpha: 0.2),
            label: '$_plazo meses',
            onChanged: (v) => setState(() => _plazo = v.round()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('6m', style: TextStyle(fontSize: 11, color: AppTheme.grisMedio)),
                Text('60m', style: TextStyle(fontSize: 11, color: AppTheme.grisMedio)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // TEA
          TextFormField(
            controller: _teaCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: const InputDecoration(
              labelText: 'TEA (%) — Tasa Efectiva Anual',
              prefixIcon: Icon(Icons.percent),
            ),
            onChanged: (_) => _recalcular(),
            validator: (v) {
              final value = double.tryParse((v ?? '').trim());
              if (value == null || value <= 0) {
                return 'Ingresa una TEA válida, por ejemplo: 28';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          // Garantía
          DropdownButtonFormField<String>(
            initialValue: _garantia,
            decoration: const InputDecoration(
              labelText: 'Garantía',
              prefixIcon: Icon(Icons.verified_user_outlined),
            ),
            items: TipoGarantia.opcionesCliente.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _garantia = val);
            },
          ),
          const SizedBox(height: 18),
          // Destino
          DropdownButtonFormField<String>(
            initialValue: _destino,
            decoration: const InputDecoration(
              labelText: 'Destino del crédito',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: _destinos
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _destino = val);
            },
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _incluyeSeguroDesgravamen,
            activeColor: AppTheme.navy,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Incluir seguro de desgravamen',
              style: TextStyle(fontSize: 14, color: AppTheme.navy),
            ),
            subtitle: const Text(
              'La cuota incluye prima de seguro de desgravamen (0.1% del capital/mes).',
              style: TextStyle(fontSize: 12, color: AppTheme.grisMedio),
            ),
            onChanged: (v) => setState(() => _incluyeSeguroDesgravamen = v ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildCuotaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.navy, Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('Cuota mensual estimada',
              style: TextStyle(color: Colors.white60, fontSize: 13)),
          if (_incluyeSeguroDesgravamen)
            const Text('(con seguro de desgravamen)',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 8),
          Text(
            'S/ ${_cuota.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppTheme.amarillo,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ResultItem('Total a pagar', 'S/ ${_totalPagar.toStringAsFixed(2)}'),
              _ResultItem(
                  'Total intereses', 'S/ ${_totalIntereses.toStringAsFixed(2)}'),
              _ResultItem('Plazo', '$_plazo meses'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label, value;
  const _ResultItem(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    ]);
  }
}
