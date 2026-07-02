import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/auth_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/home_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/ofertas_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/core/notificacion_solicitud_helper.dart';
import 'package:appbanco_pichincha_cliente/app/ui/theme/app_theme.dart';
import 'package:appbanco_pichincha_cliente/app/ui/widgets/modo_offline_banner.dart';
import 'package:appbanco_pichincha_cliente/app/ui/widgets/detalle_ahorro_modal.dart';
import 'package:appbanco_pichincha_cliente/app/ui/widgets/cliente_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cliente = Provider.of<AuthViewModel>(context, listen: false).cliente;
      if (cliente != null) {
        Provider.of<OfertasViewModel>(context, listen: false)
            .cargar(cliente.id);
      }
      revisarNotificacionesSolicitud(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      revisarNotificacionesSolicitud(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context);
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: const Text(
          'Banco Pichincha',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Consumer<OfertasViewModel>(
            builder: (_, ovm, __) {
              final count = ovm.alertasNoLeidas.length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/alertas'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.rojoError,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              vm.logout();
              Provider.of<AuthViewModel>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: vm.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.navy),
            )
          : RefreshIndicator(
              onRefresh: () => vm.recargar(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ModoOfflineBanner(),
                    const SizedBox(height: 12),
                    Text(
                      'Hola, ${vm.cliente?.primerNombre ?? ''}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aquí puedes consultar tus cuentas, créditos y solicitudes',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.grisMedio,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Banner preaprobado
                    Consumer<OfertasViewModel>(
                      builder: (_, ovm, __) {
                        if (!ovm.tienePreaprobado) {
                          return const SizedBox.shrink();
                        }
                        final pre = ovm.preaprobado!;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD100), Color(0xFFFFBF00)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.amarillo.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.navy,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '¡Crédito Preaprobado!',
                                      style: TextStyle(
                                        color: AppTheme.navy,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Hasta S/ ${pre.montoPreaprobado.toStringAsFixed(0)} — ${pre.plazoMeses} meses',
                                      style: const TextStyle(
                                        color: AppTheme.navyOscuro,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/ofertas'),
                                child: const Text(
                                  'Ver oferta',
                                  style: TextStyle(
                                    color: AppTheme.navy,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Account cards
                    if (vm.cuentaCorriente != null)
                      _TarjetaCuenta(
                        titulo: 'Cuenta Corriente',
                        numero: vm.cuentaCorriente!.numerocuenta ?? '',
                        monto: vm.formatearMonto(vm.cuentaCorriente!.saldo),
                        etiqueta: 'Saldo disponible',
                        color: AppTheme.navy,
                        icono: Icons.account_balance_outlined,
                      ),
                    if (vm.cuentaCorriente != null) const SizedBox(height: 16),
                    if (vm.cuentaAhorrosCuenta != null)
                      _TarjetaCuenta(
                        titulo: 'Cuenta de Ahorros',
                        numero: vm.cuentaAhorrosCuenta!.numerocuenta ?? '',
                        monto:
                            vm.formatearMonto(vm.cuentaAhorrosCuenta!.saldo),
                        etiqueta: 'Saldo disponible',
                        color: const Color(0xFF1565C0),
                        icono: Icons.savings_outlined,
                        onTap: () {
                          if (vm.cliente != null) {
                            DetalleAhorroModal.mostrar(
                              context,
                              vm.cuentaAhorrosCuenta!,
                              vm.cliente!,
                              vm.cuentas,
                            );
                          }
                        },
                      ),
                    if (vm.cuentaAhorrosCuenta != null)
                      const SizedBox(height: 28),

                    const Text(
                      'Accesos rápidos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _AccesoRapido(
                            icono: Icons.description_outlined,
                            label: 'Solicitudes',
                            onTap: () =>
                                Navigator.pushNamed(context, '/solicitudes'),
                          ),
                          const SizedBox(width: 16),
                          _AccesoRapido(
                            icono: Icons.calculate_outlined,
                            label: 'Simulador',
                            onTap: () =>
                                Navigator.pushNamed(context, '/preevaluacion'),
                          ),
                          const SizedBox(width: 16),
                          _AccesoRapido(
                            icono: Icons.payment,
                            label: 'Pagar',
                            onTap: () =>
                                Navigator.pushNamed(context, '/pagos'),
                          ),
                          const SizedBox(width: 16),
                          _AccesoRapido(
                            icono: Icons.history,
                            label: 'Historial',
                            onTap: () =>
                                Navigator.pushNamed(context, '/transacciones'),
                          ),
                          const SizedBox(width: 16),
                          _AccesoRapido(
                            icono: Icons.credit_score,
                            label: 'Créditos',
                            onTap: () =>
                                Navigator.pushNamed(context, '/creditos'),
                          ),
                          if (vm.cuentaAhorrosCuenta != null || (vm.cliente?.cuentasVigentes ?? 0) > 0) ...[
                            const SizedBox(width: 16),
                            _AccesoRapido(
                              icono: Icons.send_to_mobile,
                              label: 'Yape / Plin',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/yape-plin'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const ClienteBottomNavBar(selectedIndex: 0),
    );
  }
}

class _TarjetaCuenta extends StatelessWidget {
  final String titulo;
  final String numero;
  final String monto;
  final String etiqueta;
  final Color color;
  final IconData icono;
  final VoidCallback? onTap;

  const _TarjetaCuenta({
    required this.titulo,
    required this.numero,
    required this.monto,
    required this.etiqueta,
    required this.color,
    required this.icono,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Icon(icono, color: AppTheme.amarillo, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            monto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            etiqueta,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            numero,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    ),
    );
  }
}

class _AccesoRapido extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;

  const _AccesoRapido({
    required this.icono,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: AppTheme.navy, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.navy),
          ),
        ],
      ),
    );
  }
}
