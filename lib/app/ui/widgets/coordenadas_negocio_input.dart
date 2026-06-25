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
  bool _expandido = false;
  bool _obteniendoGps = false;

  @override
  void initState() {
    super.initState();
    _latCtrl = TextEditingController(
      text: widget.latitud != null ? widget.latitud!.toStringAsFixed(6) : '',
    );
    _lngCtrl = TextEditingController(
      text: widget.longitud != null ? widget.longitud!.toStringAsFixed(6) : '',
    );
    _expandido = CoordenadasUtil.parValido(widget.latitud, widget.longitud);
  }

  @override
  void didUpdateWidget(CoordenadasNegocioInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitud != oldWidget.latitud) {
      _latCtrl.text =
          widget.latitud != null ? widget.latitud!.toStringAsFixed(6) : '';
    }
    if (widget.longitud != oldWidget.longitud) {
      _lngCtrl.text =
          widget.longitud != null ? widget.longitud!.toStringAsFixed(6) : '';
    }
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _emitLat(String v) {
    final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
    widget.onLatitudChanged(parsed);
  }

  void _emitLng(String v) {
    final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
    widget.onLongitudChanged(parsed);
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
        CoordenadasUtil.parValido(widget.latitud, widget.longitud);

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
                                widget.latitud!, widget.longitud!)
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
                  onChanged: _emitLat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lngCtrl,
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
                  onChanged: _emitLng,
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
