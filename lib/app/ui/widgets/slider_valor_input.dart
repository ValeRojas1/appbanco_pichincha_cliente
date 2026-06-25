import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Control deslizante + campo manual para valores numéricos enteros.
/// Solo permite dígitos (sin puntos, comas ni caracteres especiales).
class SliderValorInput extends StatefulWidget {
  final String label;
  final String manualLabel;
  final IconData icon;
  final int min;
  final int max;
  final int divisions;
  final int value;
  final String suffix;
  final String? valuePrefix;
  final String? minLabel;
  final String? maxLabel;
  final ValueChanged<int> onChanged;
  final String? Function(int value)? validator;

  const SliderValorInput({
    super.key,
    required this.label,
    required this.manualLabel,
    required this.icon,
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.onChanged,
    this.suffix = '',
    this.valuePrefix,
    this.minLabel,
    this.maxLabel,
    this.validator,
  });

  @override
  State<SliderValorInput> createState() => _SliderValorInputState();
}

class _SliderValorInputState extends State<SliderValorInput> {
  late final TextEditingController _ctrl;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(SliderValorInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _ctrl.text != widget.value.toString()) {
      _sincronizando = true;
      _ctrl.text = widget.value.toString();
      _sincronizando = false;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int _clamp(int v) => v.clamp(widget.min, widget.max);

  void _aplicar(int raw) {
    final clamped = _clamp(raw);
    if (clamped != widget.value) {
      widget.onChanged(clamped);
    }
    final texto = clamped.toString();
    if (_ctrl.text != texto) {
      _sincronizando = true;
      _ctrl.text = texto;
      _sincronizando = false;
    }
    setState(() {});
  }

  void _desdeSlider(double v) => _aplicar(v.round());

  void _desdeTexto(String texto) {
    if (_sincronizando) return;
    if (texto.isEmpty) {
      setState(() {});
      return;
    }
    final parsed = int.tryParse(texto);
    if (parsed != null) {
      _aplicar(parsed);
    }
  }

  String _etiquetaValor() {
    final num = widget.value.toString();
    if (widget.valuePrefix != null) return '${widget.valuePrefix}$num';
    if (widget.suffix.isEmpty) return num;
    return '$num ${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: 18, color: AppTheme.navy),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navy,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              _etiquetaValor(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Slider(
          value: widget.value.toDouble(),
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          divisions: widget.divisions,
          activeColor: AppTheme.navy,
          inactiveColor: AppTheme.navy.withValues(alpha: 0.2),
          label: _etiquetaValor(),
          onChanged: _desdeSlider,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.minLabel ?? '${widget.min}',
                style: const TextStyle(fontSize: 11, color: AppTheme.grisMedio),
              ),
              Text(
                widget.maxLabel ?? '${widget.max}',
                style: const TextStyle(fontSize: 11, color: AppTheme.grisMedio),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: widget.manualLabel,
            prefixIcon: widget.valuePrefix == null
                ? Icon(widget.icon)
                : null,
            prefixText: widget.valuePrefix,
            suffixText: widget.suffix.isNotEmpty && widget.valuePrefix == null
                ? widget.suffix
                : null,
          ),
          onChanged: _desdeTexto,
          validator: (_) {
            final texto = _ctrl.text.trim();
            if (texto.isEmpty) {
              return 'Ingresa un valor';
            }
            final parsed = int.tryParse(texto);
            if (parsed == null) {
              return 'Usa solo números enteros';
            }
            if (parsed < widget.min || parsed > widget.max) {
              return 'Debe estar entre ${widget.min} y ${widget.max}';
            }
            return widget.validator?.call(parsed);
          },
        ),
      ],
    );
  }
}
