import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/prestamo_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';
import '../ui/theme/app_theme.dart';

class SolicitudScreen extends StatefulWidget {
  const SolicitudScreen({super.key});

  @override
  State<SolicitudScreen> createState() => _SolicitudScreenState();
}

class _SolicitudScreenState extends State<SolicitudScreen> {
  final _montoController = TextEditingController();
  final _plazoController = TextEditingController();
  final _motivoController = TextEditingController();
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<HomeViewModel>(context, listen: false).usuario;
      if (user != null) {
        Provider.of<PrestamoViewModel>(context, listen: false)
            .cargarSolicitudes(user.userid);
      }
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    _plazoController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _enviarSolicitud() async {
    final montoText = _montoController.text.trim();
    final plazoText = _plazoController.text.trim();
    if (montoText.isEmpty || plazoText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final user = Provider.of<HomeViewModel>(context, listen: false).usuario;
    if (user == null) return;

    setState(() => _enviando = true);

    final vm = Provider.of<PrestamoViewModel>(context, listen: false);
    final ok = await vm.crearSolicitud({
      'userid': user.userid,
      'monto': double.tryParse(montoText) ?? 0,
      'plazomeses': int.tryParse(plazoText) ?? 0,
      'proposito': _motivoController.text.trim(),
      'estado': 'pendiente',
    });

    setState(() => _enviando = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solicitud enviada correctamente'),
            backgroundColor: AppTheme.verdeSaldo),
      );
      _montoController.clear();
      _plazoController.clear();
      _motivoController.clear();
      await vm.cargarSolicitudes(user.userid);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al enviar solicitud'),
            backgroundColor: AppTheme.rojoError),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PrestamoViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(title: const Text('Solicitar Préstamo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nueva Solicitud',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto solicitado (S/)',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _plazoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Plazo (meses)',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _motivoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviarSolicitud,
                child: _enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.navy,
                        ),
                      )
                    : const Text('ENVIAR SOLICITUD'),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Mis Solicitudes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 12),
            if (vm.loading)
              const Center(child: CircularProgressIndicator(color: AppTheme.navy))
            else if (vm.solicitudes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No hay solicitudes previas')),
              )
            else
              ...vm.solicitudes.map(
                (s) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: s.estado == 'aprobado'
                          ? AppTheme.verdeSaldo.withValues(alpha: 0.1)
                          : AppTheme.amarillo.withValues(alpha: 0.3),
                      child: Icon(
                        s.estado == 'aprobado'
                            ? Icons.check_circle
                            : Icons.hourglass_empty,
                        color: s.estado == 'aprobado'
                            ? AppTheme.verdeSaldo
                            : AppTheme.navy,
                      ),
                    ),
                    title: Text('S/ ${s.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text('${s.plazomeses} meses - ${s.estado}'),
                    trailing: s.cuotamensual != null
                        ? Text(
                            'Cuota: S/ ${s.cuotamensual!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.grisMedio),
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
