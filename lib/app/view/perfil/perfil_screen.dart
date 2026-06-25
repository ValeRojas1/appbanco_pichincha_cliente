import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/perfil_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/auth_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/home_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/ui/theme/app_theme.dart';
import 'package:appbanco_pichincha_cliente/app/ui/widgets/cliente_bottom_nav_bar.dart';
import 'package:appbanco_pichincha_cliente/app/ui/widgets/cliente_app_bar_leading.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
      if (cliente != null) {
        Provider.of<PerfilViewModel>(context, listen: false).cargar(cliente);
      }
    });
  }

  void _cerrarSesion() {
    Provider.of<HomeViewModel>(context, listen: false).logout();
    Provider.of<AuthViewModel>(context, listen: false).logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: const ClienteAppBarLeading(),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Inicio',
            onPressed: () => irAlInicioCliente(context),
          ),
        ],
      ),
      bottomNavigationBar: const ClienteBottomNavBar(selectedIndex: 3),
      body: Consumer<PerfilViewModel>(
        builder: (_, vm, __) {
          if (vm.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.navy),
            );
          }
          final c = vm.cliente;
          if (c == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No pudimos mostrar tu perfil en este momento.\nCierra y vuelve a abrir esta sección.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.grisMedio, fontSize: 14),
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Header card
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.amarillo.withValues(alpha: 0.2),
                        child: Text(
                          c.primerNombre[0],
                          style: const TextStyle(
                            color: AppTheme.amarillo,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        c.nombreCompleto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DNI: ${c.documento}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Situación crediticia
                _seccionTitulo('Resumen de tu historial crediticio'),
                const SizedBox(height: 12),
                _infoCard([
                  _itemInfo(
                    'Deuda total reportada',
                    Text(
                      'S/ ${c.deudaTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _itemInfo(
                    'Cuentas con atraso',
                    Text(
                      '${c.cuentasEnMora}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: c.cuentasEnMora > 0
                            ? AppTheme.rojoError
                            : AppTheme.verdeSaldo,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _itemInfo(
                    'Máximo de días de atraso',
                    Text(
                      c.diasMayorMora > 0
                          ? '${c.diasMayorMora} días'
                          : 'Sin atrasos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: c.diasMayorMora > 0
                            ? AppTheme.rojoError
                            : AppTheme.verdeSaldo,
                      ),
                    ),
                  ),
                  if (c.fechaUltimoPago != null) const Divider(height: 1),
                  if (c.fechaUltimoPago != null)
                    _itemInfo(
                      'Último pago realizado',
                      Text(
                        c.fechaUltimoPago!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                ]),
                const SizedBox(height: 20),

                // Datos personales
                _seccionTitulo('Datos Personales'),
                const SizedBox(height: 12),
                _infoCard([
                  if (c.telefono != null)
                    _itemInfo('Teléfono', Text(c.telefono!)),
                  if (c.tipoNegocio != null) ...[
                    const Divider(height: 1),
                    _itemInfo('Tipo de Negocio', Text(c.tipoNegocio!)),
                  ],
                  const Divider(height: 1),
                  _itemInfo(
                    'Cuentas activas',
                    Text(
                      '${c.cuentasVigentes}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _cerrarSesion,
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          'Cierra tu sesión',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.rojoError,
                          side: BorderSide(
                            color: AppTheme.rojoError.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Saldrás de forma segura de tu cuenta en este dispositivo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.grisMedio.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _seccionTitulo(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.navy,
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _itemInfo(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.grisMedio, fontSize: 14),
          ),
          value,
        ],
      ),
    );
  }
}
