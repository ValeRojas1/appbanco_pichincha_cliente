import 'package:flutter/material.dart';
import '../view/auth/login_screen.dart';
import '../view/home/dashboard_screen.dart';
import '../view/cuentas_screen.dart';
import '../view/transacciones_screen.dart';
import '../view/pagos_screen.dart';
import '../view/solicitud_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String cuentas = '/cuentas';
  static const String transacciones = '/transacciones';
  static const String pagos = '/pagos';
  static const String solicitud = '/solicitud';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
      case cuentas:
        return MaterialPageRoute(
          builder: (_) => const CuentasScreen(),
        );
      case transacciones:
        return MaterialPageRoute(
          builder: (_) => const TransaccionesScreen(),
        );
      case pagos:
        return MaterialPageRoute(
          builder: (_) => const PagosScreen(),
        );
      case solicitud:
        return MaterialPageRoute(
          builder: (_) => const SolicitudScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }
}
