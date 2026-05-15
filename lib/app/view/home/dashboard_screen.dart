import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../../ui/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: Image.asset('assets/images/logo_texto.png',
            height: 28,
            errorBuilder: (_, __, ___) => const Text(
                  'Banco Pichincha',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              'Hola, ${vm.usuario.nombre.split(' ').first} 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bienvenido a tu banca personal',
              style: TextStyle(fontSize: 14, color: AppTheme.grisMedio),
            ),

            const SizedBox(height: 24),

            // Tarjeta Ahorros
            _TarjetaCuenta(
              titulo: 'Cuenta de Ahorros',
              numero: vm.cuentaAhorros.numeroCuenta,
              monto: vm.formatearMonto(vm.cuentaAhorros.saldo),
              etiqueta: 'Saldo disponible',
              color: AppTheme.navy,
              icono: Icons.savings_outlined,
            ),

            const SizedBox(height: 16),

            // Tarjeta Crédito
            _TarjetaCuenta(
              titulo: 'Crédito Activo',
              numero: vm.cuentaCredito.numeroCuenta,
              monto: vm.formatearMonto(vm.cuentaCredito.montoPendiente!),
              etiqueta: 'Monto pendiente',
              color: const Color(0xFF1565C0),
              icono: Icons.credit_card_outlined,
            ),

            const SizedBox(height: 28),

            // Accesos rápidos
            const Text(
              'Accesos rápidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AccesoRapido(icono: Icons.swap_horiz, label: 'Transferir'),
                _AccesoRapido(icono: Icons.payment, label: 'Pagar'),
                _AccesoRapido(icono: Icons.history, label: 'Historial'),
                _AccesoRapido(icono: Icons.qr_code, label: 'QR'),
              ],
            ),
          ],
        ),
      ),

      // BottomNavigationBar — solo Inicio activo en S9
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: vm.tabIndex,
        onTap: vm.cambiarTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            label: 'Cuentas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_score_outlined),
            label: 'Créditos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
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

  const _TarjetaCuenta({
    required this.titulo,
    required this.numero,
    required this.monto,
    required this.etiqueta,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
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
              Text(titulo,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
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
          Text(etiqueta,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 10),
          Text(
            numero,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _AccesoRapido extends StatelessWidget {
  final IconData icono;
  final String label;

  const _AccesoRapido({required this.icono, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.navy.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icono, color: AppTheme.navy, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.navy)),
      ],
    );
  }
}