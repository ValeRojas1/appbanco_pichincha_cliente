import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/consulta_buro_service.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../ui/theme/app_theme.dart';

class ConsentimientoScreen extends StatefulWidget {
  const ConsentimientoScreen({super.key});

  @override
  State<ConsentimientoScreen> createState() => _ConsentimientoScreenState();
}

class _ConsentimientoScreenState extends State<ConsentimientoScreen> {
  final List<Offset?> _points = [];
  bool _loading = false;
  bool _aceptaTerminos = false;

  Future<void> _enviarConsentimiento() async {
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Marca la casilla de autorización para continuar con la consulta.')),
      );
      return;
    }
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Dibuja tu firma en el recuadro para confirmar tu autorización.')),
      );
      return;
    }

    setState(() => _loading = true);

    final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
    if (cliente == null) {
      setState(() => _loading = false);
      return;
    }

    final buroService = ConsultaBuroService();

    // 1. Verificar si está en lista negra
    final enListaNegra = await buroService.verificarListaNegra(cliente.documento);
    if (enListaNegra && mounted) {
      setState(() => _loading = false);
      _mostrarBloqueoListaNegra();
      return;
    }

    // 2. Consultar buró
    const firmaMockBase64 = 'iVBORw0KGgoAAAANSUhEUgAAADIA...'; // Mock base64 signature
    final resultado = await buroService.consultarBuro(cliente.documento, firmaMockBase64);

    setState(() => _loading = false);

    if (resultado != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/resultado-buro',
        arguments: resultado,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No pudimos completar la consulta. Revisa tu conexión e inténtalo de nuevo.')),
      );
    }
  }

  void _mostrarBloqueoListaNegra() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.rojoError),
            SizedBox(width: 8),
            Text('Solicitud no disponible por ahora',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navy)),
          ],
        ),
        content: const Text(
          'Por el momento no podemos continuar con esta solicitud. Un asesor puede orientarte sobre otras opciones disponibles para ti.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Regresar a pantalla anterior
            },
            child: const Text('Entendido', style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Autorización de consulta')),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.navy),
                  SizedBox(height: 16),
                  Text('Consultando tu historial crediticio de forma segura...',
                      style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consentimiento para Consulta en Centrales de Riesgo',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navy),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'De conformidad con la Ley N° 29733 (Ley de Protección de Datos Personales), autorizo expresamente al Banco Pichincha a realizar consultas sobre mi comportamiento de pago, historial crediticio y situación financiera en las centrales de riesgo públicas y privadas.',
                    style: TextStyle(fontSize: 13, color: AppTheme.navyOscuro, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _aceptaTerminos,
                        activeColor: AppTheme.navy,
                        checkColor: AppTheme.amarillo,
                        onChanged: (val) {
                          setState(() => _aceptaTerminos = val ?? false);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Acepto y doy mi consentimiento expreso para la consulta.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Firma Canvas
                  const Text(
                    'Firme en el recuadro:',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navy),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.grisMedio.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GestureDetector(
                        onPanUpdate: (DragUpdateDetails details) {
                          setState(() {
                            // offset relative to canvas container
                            _points.add(details.localPosition);
                          });
                        },
                        onPanEnd: (DragEndDetails details) {
                          _points.add(null);
                        },
                        child: CustomPaint(
                          painter: SignaturePainter(points: _points),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _points.clear());
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Limpiar Firma'),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.rojoError),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _aceptaTerminos ? _enviarConsentimiento : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Aceptar y continuar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.navy
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}
