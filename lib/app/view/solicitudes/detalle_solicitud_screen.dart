import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/tipo_garantia.dart';
import '../../core/coordenadas_util.dart';
import '../../viewmodel/solicitud_credito_viewmodel.dart';
import '../../model/solicitud_documento_model.dart';
import '../../services/solicitud_documento_service.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/cliente_app_bar_leading.dart';
import '../../ui/widgets/cliente_bottom_nav_bar.dart';

class DetalleSolicitudScreen extends StatelessWidget {
  const DetalleSolicitudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SolicitudCreditoViewModel>(
      builder: (_, vm, __) {
        final s = vm.seleccionada;
        if (s == null) {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Selecciona una solicitud de la lista para ver su detalle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.grisMedio, fontSize: 14),
                ),
              ),
            ),
          );
        }
        final estado = s.estadoEnum;
        return Scaffold(
          backgroundColor: AppTheme.grisClaro,
          appBar: AppBar(
            title: const Text('Detalle de Solicitud'),
            leading: const ClienteAppBarLeading(),
            actions: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Inicio',
                onPressed: () => irAlInicioCliente(context),
              ),
            ],
          ),
          bottomNavigationBar: const ClienteBottomNavBar(selectedIndex: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [estado.color, estado.color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: estado.color.withValues(alpha: 0.3),
                        blurRadius: 12, offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(estado.icono, color: Colors.white, size: 40),
                      const SizedBox(height: 10),
                      Text(estado.label,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('S/ ${s.monto.toStringAsFixed(2)} — ${s.plazoMeses} meses',
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 10),
                      Text(
                        estado.mensajeCliente,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Datos del negocio
                if ((s.nombreNegocio != null && s.nombreNegocio!.isNotEmpty) ||
                    (s.direccionNegocio != null && s.direccionNegocio!.isNotEmpty) ||
                    s.ingresosEstimados != null ||
                    s.gastosEstimados != null ||
                    s.antiguedadMeses != null) ...[
                  _seccionTitulo('Datos del Negocio'),
                  const SizedBox(height: 12),
                  _tarjetaInfo([
                    if (s.tipoNegocio != null && s.tipoNegocio!.isNotEmpty)
                      _item('Tipo de negocio', s.tipoNegocio!),
                    if (s.nombreNegocio != null && s.nombreNegocio!.isNotEmpty)
                      _item('Nombre', s.nombreNegocio!),
                    if (s.direccionNegocio != null && s.direccionNegocio!.isNotEmpty)
                      _item('Dirección', s.direccionNegocio!),
                    if (CoordenadasUtil.parValido(
                        s.latitudNegocio, s.longitudNegocio))
                      _item(
                        'Coordenadas GPS',
                        CoordenadasUtil.formatearCoordenadas(
                          s.latitudNegocio!,
                          s.longitudNegocio!,
                        ),
                      ),
                    if (s.ingresosEstimados != null)
                      _item('Ingresos mensuales', 'S/ ${s.ingresosEstimados!.toStringAsFixed(0)}'),
                    if (s.gastosEstimados != null)
                      _item('Gastos mensuales', 'S/ ${s.gastosEstimados!.toStringAsFixed(0)}'),
                    if (s.antiguedadMeses != null)
                      _item('Antigüedad', '${s.antiguedadMeses} meses'),
                  ]),
                  const SizedBox(height: 20),
                ],
                // Datos del crédito
                _seccionTitulo('Datos del Crédito'),
                const SizedBox(height: 12),
                _tarjetaInfo([
                  _item('Monto', 'S/ ${s.monto.toStringAsFixed(2)}'),
                  _item('Plazo', '${s.plazoMeses} meses'),
                  _item('TEA', '${s.tea}%'),
                  _item('Cuota Mensual', 'S/ ${s.cuotaMensual.toStringAsFixed(2)}'),
                  if (s.tipoGarantia != null)
                    _item('Garantía', TipoGarantia.etiqueta(s.tipoGarantia)),
                  if (s.numeroExpediente != null) _item('N° Expediente', s.numeroExpediente!),
                  if (s.analistaAsignado != null) _item('Analista', s.analistaAsignado!),
                ]),
                const SizedBox(height: 20),
                // Fechas
                _seccionTitulo('Fechas'),
                const SizedBox(height: 12),
                _tarjetaInfo([
                  if (s.fechaEnvio != null) _item('Envío', _formatFecha(s.fechaEnvio!)),
                  if (s.fechaAprobacion != null) _item('Aprobación', _formatFecha(s.fechaAprobacion!)),
                  if (s.fechaDesembolso != null) _item('Desembolso', _formatFecha(s.fechaDesembolso!)),
                ]),
                if (s.motivoRechazo != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.rojoError.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.rojoError.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.rojoError, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Detalle del resultado',
                                  style: TextStyle(color: AppTheme.rojoError,
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(s.motivoRechazo!,
                                  style: const TextStyle(color: AppTheme.rojoError, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Documentos
                _seccionTitulo('Documentos del Expediente'),
                const SizedBox(height: 12),
                if (vm.documentos.isEmpty)
                  const Text(
                      'Aún no hay documentos en tu expediente.\nSube los pendientes para avanzar con tu solicitud.',
                      style: TextStyle(color: AppTheme.grisMedio, fontSize: 13))
                else
                  ...vm.documentos.map((d) => _DocumentoItem(
                    documento: d,
                    solicitudId: s.id,
                  )),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  Widget _seccionTitulo(String titulo) =>
      Text(titulo, style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navy));

  Widget _tarjetaInfo(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.grisMedio, fontSize: 14)),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navy),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _DocumentoItem extends StatefulWidget {
  final SolicitudDocumentoModel documento;
  final String solicitudId;
  const _DocumentoItem({required this.documento, required this.solicitudId});

  @override
  State<_DocumentoItem> createState() => _DocumentoItemState();
}

class _DocumentoItemState extends State<_DocumentoItem> {
  bool _subiendo = false;

  Future<void> _subirDocumento() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file == null) return;

    setState(() => _subiendo = true);
    final service = SolicitudDocumentoService();
    final ok = await service.subirDocumento(
        widget.solicitudId, widget.documento.tipoDocumento, File(file.path));
    setState(() => _subiendo = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Documento recibido. Lo revisaremos a la brevedad.'
            : 'No pudimos subir el documento. Revisa tu conexión e inténtalo de nuevo.'),
        backgroundColor: ok ? AppTheme.verdeSaldo : AppTheme.rojoError,
      ));
    }
  }

  Future<void> _verDocumento() async {
    final d = widget.documento;
    if (d.storagePath.isEmpty) return;
    setState(() => _subiendo = true);
    final service = SolicitudDocumentoService();
    final url = await service.getUrlDocumento(d.storagePath);
    setState(() => _subiendo = false);
    if (url != null && mounted) {
      Navigator.pushNamed(context, '/visor-documento', arguments: {
        'titulo': d.tipoLabel,
        'url': url,
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No pudimos abrir el documento. Intenta de nuevo en unos momentos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.documento;
    final color = d.estaListo ? AppTheme.verdeSaldo : AppTheme.grisMedio;
    final icon = d.estaListo ? Icons.check_circle : Icons.upload_file;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: d.estaListo ? _verDocumento : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.tipoLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      d.estaListo
                          ? 'Recibido — toca para ver'
                          : (d.obligatorio
                              ? 'Pendiente — necesario para continuar'
                              : 'Pendiente — opcional'),
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ],
                ),
              ),
              if (!d.estaListo)
                _subiendo
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navy))
                    : TextButton.icon(
                        onPressed: _subirDocumento,
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text('Subir'),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.navy),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
