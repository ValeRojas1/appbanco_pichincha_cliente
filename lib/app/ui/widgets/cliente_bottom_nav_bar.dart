import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/home_viewmodel.dart';

/// Barra inferior compartida: Inicio, Cuentas, Créditos y Perfil.
class ClienteBottomNavBar extends StatelessWidget {
  /// 0 Inicio, 1 Cuentas, 2 Créditos, 3 Perfil. Null = usa [HomeViewModel.tabIndex].
  final int? selectedIndex;

  const ClienteBottomNavBar({super.key, this.selectedIndex});

  static const _rutas = [
    '/dashboard',
    '/cuentas',
    '/creditos',
    '/perfil',
  ];

  void _ir(BuildContext context, int index) {
    if (selectedIndex == index) return;

    Provider.of<HomeViewModel>(context, listen: false).cambiarTab(index);

    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
      return;
    }

    // Mantiene el dashboard como base del stack para que el botón atrás de
    // cada pantalla regrese al inicio en lugar de dejar el navegador vacío.
    Navigator.pushNamedAndRemoveUntil(
      context,
      _rutas[index],
      ModalRoute.withName('/dashboard'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = selectedIndex ??
        Provider.of<HomeViewModel>(context, listen: false).tabIndex;

    return BottomNavigationBar(
      currentIndex: index.clamp(0, 3),
      onTap: (i) => _ir(context, i),
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
    );
  }
}

/// Navega al dashboard limpiando el stack.
void irAlInicioCliente(BuildContext context) {
  Provider.of<HomeViewModel>(context, listen: false).cambiarTab(0);
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/dashboard',
    (route) => false,
  );
}
