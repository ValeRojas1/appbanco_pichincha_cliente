import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/coordenadas_util.dart';
import '../theme/app_theme.dart';

/// Captura opcional de latitud/longitud del local del negocio.
class CoordenadasNegocioInput extends StatefulWidget {
  final double? latitud;
  final double? longitud;
  final ValueChanged<double?> onLatitudChanged;
  final ValueChanged<double?> onLongitudChanged;

  const CoordenadasNegocioInput({
    super.key,
    this.latitud,
    this.longitud,
    required this.onLatitudChanged,
    required this.onLongitudChanged,
  });

  @override
  State<CoordenadasNegocioInput> createState() => _CoordenadasNegocioInputState();
}

class _CoordenadasNegocioInputState extends State<CoordenadasNegocioInput> {
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final FocusNode _latFocus;
  late final FocusNode _lngFocus;
  bool _expandido = false;
  bool _obteniendoGps = false;
  double? _latitudLocal;
  double? _longitudLocal;

  @override
  void initState() {
    super.initState();
    _latitudLocal = widget.latitud;
    _longitudLocal = widget.longitud;
    _latCtrl = TextEditingController(text: _textoInicial(widget.latitud));
    _lngCtrl = TextEditingController(text: _textoInicial(widget.longitud));
    _latFocus = FocusNode();
    _lngFocus = FocusNode();
    _expandido = CoordenadasUtil.parValido(_latitudLocal, _longitudLocal);
  }

  String _textoInicial(double? valor) {
    if (valor == null) return '';
    return valor.toStringAsFixed(6);
  }

  @override
  void didUpdateWidget(CoordenadasNegocioInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_latFocus.hasFocus && widget.latitud != oldWidget.latitud) {
      _latitudLocal = widget.latitud;
      _latCtrl.text = _textoInicial(widget.latitud);
    }
    if (!_lngFocus.hasFocus && widget.longitud != oldWidget.longitud) {
      _longitudLocal = widget.longitud;
      _lngCtrl.text = _textoInicial(widget.longitud);
    }
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _latFocus.dispose();
    _lngFocus.dispose();
    super.dispose();
  }

  double? _parseTexto(String v) {
    final t = v.trim().replaceAll(',', '.');
    if (t.isEmpty || t == '-' || t == '.' || t == '-.') return null;
    return double.tryParse(t);
  }

  void _emitirLatitud() {
    final parsed = _parseTexto(_latCtrl.text);
    _latitudLocal = parsed;
    widget.onLatitudChanged(parsed);
    setState(() {});
  }

  void _emitirLongitud() {
    final parsed = _parseTexto(_lngCtrl.text);
    _longitudLocal = parsed;
    widget.onLongitudChanged(parsed);
    setState(() {});
  }

  Future<void> _usarUbicacionActual() async {
    setState(() => _obteniendoGps = true);
    try {
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Activa el permiso de ubicación o ingresa las coordenadas manualmente.',
              ),
              backgroundColor: AppTheme.rojoError,
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      if (!mounted) return;
      setState(() {
        _expandido = true;
        _latitudLocal = pos.latitude;
        _longitudLocal = pos.longitude;
        _latCtrl.text = pos.latitude.toStringAsFixed(6);
        _lngCtrl.text = pos.longitude.toStringAsFixed(6);
      });
      widget.onLatitudChanged(pos.latitude);
      widget.onLongitudChanged(pos.longitude);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo obtener la ubicación. Ingresa latitud y longitud manualmente.',
            ),
            backgroundColor: AppTheme.rojoError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _obteniendoGps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tieneCoords =
        CoordenadasUtil.parValido(_latitudLocal, _longitudLocal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expandido = !_expandido),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.grisClaro,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tieneCoords
                    ? AppTheme.verdeSaldo.withValues(alpha: 0.5)
                    : AppTheme.grisMedio.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.my_location_outlined,
                  color: tieneCoords ? AppTheme.verdeSaldo : AppTheme.navy,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación exacta (opcional)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navy,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        tieneCoords
                            ? CoordenadasUtil.formatearCoordenadas(
                                _latitudLocal!, _longitudLocal!)
                            : 'Latitud y longitud para que el asesor ubique tu local',
                        style: const TextStyle(
                          color: AppTheme.grisMedio,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expandido ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.grisMedio,
                ),
              ],
            ),
          ),
        ),
        if (_expandido) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _obteniendoGps ? null : _usarUbicacionActual,
            icon: _obteniendoGps
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.gps_fixed, size: 18),
            label: Text(
              _obteniendoGps ? 'Obteniendo GPS...' : 'Usar mi ubicación actual',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.navy,
              side: const BorderSide(color: AppTheme.navy),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latCtrl,
                  focusNode: _latFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d*[.,]?\d*'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Latitud',
                    hintText: '-12.066400',
                    isDense: true,
                  ),
                  validator: CoordenadasUtil.validarLatitudTexto,
                  onEditingComplete: _emitirLatitud,
                  onTapOutside: (_) {
                    _latFocus.unfocus();
                    _emitirLatitud();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lngCtrl,
                  focusNode: _lngFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d*[.,]?\d*'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Longitud',
                    hintText: '-75.213700',
                    isDense: true,
                  ),
                  validator: CoordenadasUtil.validarLongitudTexto,
                  onEditingComplete: _emitirLongitud,
                  onTapOutside: (_) {
                    _lngFocus.unfocus();
                    _emitirLongitud();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Puedes copiar las coordenadas desde Google Maps (mantén pulsado el mapa).',
            style: TextStyle(fontSize: 11, color: AppTheme.grisMedio),
          ),
        ],
      ],
    );
  }
}
