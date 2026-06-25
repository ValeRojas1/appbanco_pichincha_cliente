import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/preevaluacion_service.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../model/preevaluacion_result_model.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/coordenadas_negocio_input.dart';
import '../solicitudes/solicitud_credito_screen.dart';

class PreEvaluacionScreen extends StatefulWidget {
  const PreEvaluacionScreen({super.key});

  @override
  State<PreEvaluacionScreen> createState() => _PreEvaluacionScreenState();
}

class _PreEvaluacionScreenState extends State<PreEvaluacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ingresosController = TextEditingController();
  final _montoController = TextEditingController();
  final _nombreNegocioController = TextEditingController();
  final _direccionNegocioController = TextEditingController();

  String _tipoNegocio = 'Comercio';
  String _destino = 'Capital de Trabajo';
  double? _latitudNegocio;
  double? _longitudNegocio;
  bool _loading = false;
  PreEvaluacionResultadoModel? _resultado;

  final List<String> _tiposNegocio = ['Comercio', 'Servicios', 'Producción', 'Transporte', 'Otros'];
  final List<String> _destinos = ['Capital de Trabajo', 'Activo Fijo', 'Consumo', 'Construcción / Vivienda'];

  @override
  void dispose() {
    _ingresosController.dispose();
    _montoController.dispose();
    _nombreNegocioController.dispose();
    _direccionNegocioController.dispose();
    super.dispose();
  }

  Future<void> _enviarPreEvaluacion() async {
    if (!_formKey.currentState!.validate()) return;

    final ingresos = double.tryParse(_ingresosController.text.trim()) ?? 0.0;
    final monto = double.tryParse(_montoController.text.trim()) ?? 0.0;

    setState(() {
      _loading = true;
      _resultado = null;
    });

    final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
    if (cliente == null) {
      setState(() => _loading = false);
      return;
    }

    final service = PreEvaluacionService();
    final res = await service.preEvaluar(
      dni: cliente.documento,
      ingresos: ingresos,
      tipoNegocio: _tipoNegocio,
      monto: monto,
      destino: _destino,
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _resultado = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Simulador & Pre-Evaluación')),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.navy),
                  SizedBox(height: 16),
                  Text('Estamos calculando tu resultado estimado...',
                      style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_resultado == null) ...[
                    const Text(
                      'Conoce tu elegibilidad estimada',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navy),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Completa estos datos y te mostraremos un resultado orientativo para tu crédito.',
                      style: TextStyle(fontSize: 13, color: AppTheme.grisMedio),
                    ),
                    const SizedBox(height: 20),
                    _buildForm(),
                  ] else
                    _buildResultadoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _ingresosController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Ingresos Mensuales Promedio (S/)',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tus ingresos mensuales promedio';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Usa solo números, por ejemplo: 3500';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoNegocio,
              decoration: const InputDecoration(
                labelText: 'Tipo de Negocio / Actividad',
                prefixIcon: Icon(Icons.store_mall_directory_outlined),
              ),
              items: _tiposNegocio
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _tipoNegocio = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreNegocioController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre del negocio',
                prefixIcon: Icon(Icons.store_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el nombre de tu negocio';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionNegocioController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Dirección del negocio',
                hintText: 'Ej: Av. Principal 123, distrito, referencia',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa la dirección de tu negocio';
                }
                if (value.trim().length < 10) {
                  return 'Describe la dirección con más detalle';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CoordenadasNegocioInput(
              latitud: _latitudNegocio,
              longitud: _longitudNegocio,
              onLatitudChanged: (v) => setState(() => _latitudNegocio = v),
              onLongitudChanged: (v) => setState(() => _longitudNegocio = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto de Crédito Deseado (S/)',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el monto que deseas solicitar';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Usa solo números, por ejemplo: 10000';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _destino,
              decoration: const InputDecoration(
                labelText: 'Destino del Crédito',
                prefixIcon: Icon(Icons.payment_outlined),
              ),
              items: _destinos
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _destino = val);
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enviarPreEvaluacion,
                child: const Text('Ver mi resultado estimado'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tras ver tu resultado podrás solicitar crédito con un asesor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.grisMedio),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoCard() {
    final r = _resultado!;
    Color colorTheme;
    IconData icon;
    String statusTitle;

    if (r.esAprobado) {
      colorTheme = AppTheme.verdeSaldo;
      icon = Icons.check_circle_outline;
      statusTitle = 'Elegible preliminarmente';
    } else if (r.esObservado) {
      colorTheme = AppTheme.amarillo;
      icon = Icons.warning_amber_outlined;
      statusTitle = 'En revisión adicional';
    } else {
      colorTheme = AppTheme.rojoError;
      icon = Icons.cancel_outlined;
      statusTitle = 'No elegible por ahora';
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              )
            ],
            border: Border.all(color: colorTheme.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: colorTheme, size: 64),
              const SizedBox(height: 16),
              Text(
                statusTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTheme),
              ),
              const SizedBox(height: 14),
              Text(
                r.mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.navy, height: 1.4),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Monto Solicitado', style: TextStyle(color: AppTheme.grisMedio)),
                  Text('S/ ${r.monto.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navy)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        if (r.puedeSolicitarCredito) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _irASolicitud(r.monto),
              child: const Text('Solicitar este crédito'),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (r.evaluacionLocal) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.amarillo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppTheme.navy),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resultado calculado en el dispositivo. Se confirmará al conectar con el servidor.',
                    style: TextStyle(fontSize: 12, color: AppTheme.navy),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _resultado = null;
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.navy),
              foregroundColor: AppTheme.navy,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Probar con otros montos'),
          ),
        ),
      ],
    );
  }

  void _irASolicitud(double monto) {
    final ingresos = double.tryParse(_ingresosController.text.trim()) ?? 0.0;
    Navigator.pushNamed(
      context,
      '/solicitud-credito',
      arguments: SolicitudCreditoArgs(
        monto: monto,
        destino: _destino,
        ingresos: ingresos,
        tipoNegocio: _tipoNegocio,
        nombreNegocio: _nombreNegocioController.text.trim(),
        direccionNegocio: _direccionNegocioController.text.trim(),
        latitudNegocio: _latitudNegocio,
        longitudNegocio: _longitudNegocio,
      ),
    );
  }
}
