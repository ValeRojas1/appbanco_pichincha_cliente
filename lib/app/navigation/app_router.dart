import 'package:flutter/material.dart';
import '../view/auth/login_screen.dart';
import '../view/auth/registro_screen.dart';
import '../view/home/dashboard_screen.dart';
import '../view/cuentas_screen.dart';
import '../view/transacciones_screen.dart';
import '../view/pagos_screen.dart';
import '../view/perfil/perfil_screen.dart';
import '../view/creditos/creditos_screen.dart';
import '../view/creditos/detalle_credito_screen.dart';
import '../view/creditos/simulador_cuota_screen.dart';
import '../view/solicitudes/solicitudes_screen.dart';
import '../view/solicitudes/detalle_solicitud_screen.dart';
import '../view/solicitudes/solicitud_credito_screen.dart';
import '../view/solicitudes/visor_documento_screen.dart';
import '../view/ofertas/ofertas_screen.dart';
import '../view/buro/consentimiento_screen.dart';
import '../view/buro/resultado_buro_screen.dart';
import '../view/simulador/preevaluacion_screen.dart';
import '../view/yape_plin/yape_plin_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String registro = '/registro';
  static const String dashboard = '/dashboard';
  static const String cuentas = '/cuentas';
  static const String transacciones = '/transacciones';
  static const String pagos = '/pagos';
  static const String perfil = '/perfil';
  static const String creditos = '/creditos';
  static const String creditoDetalle = '/credito-detalle';
  static const String simuladorCuota = '/simulador-cuota';
  static const String solicitudes = '/solicitudes';
  static const String solicitudDetalle = '/solicitud-detalle';
  static const String solicitudCredito = '/solicitud-credito';
  static const String visorDocumento = '/visor-documento';
  static const String ofertas = '/ofertas';
  static const String alertas = '/alertas';
  static const String consentimiento = '/consentimiento';
  static const String resultadoBuro = '/resultado-buro';
  static const String preevaluacion = '/preevaluacion';
  static const String yapePlin = '/yape-plin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case registro:
        return MaterialPageRoute(
          builder: (_) => const RegistroScreen(),
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
      case perfil:
        return MaterialPageRoute(
          builder: (_) => const PerfilScreen(),
        );
      case creditos:
        return MaterialPageRoute(
          builder: (_) => const CreditosScreen(),
        );
      case creditoDetalle:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DetalleCreditoScreen(),
        );
      case simuladorCuota:
        return MaterialPageRoute(
          builder: (_) => const SimuladorCuotaScreen(),
        );
      case solicitudes:
        return MaterialPageRoute(
          builder: (_) => const SolicitudesScreen(),
        );
      case solicitudDetalle:
        return MaterialPageRoute(
          builder: (_) => const DetalleSolicitudScreen(),
        );
      case solicitudCredito:
        final args = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SolicitudCreditoScreen(
            args: args is SolicitudCreditoArgs ? args : null,
          ),
        );
      case visorDocumento:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VisorDocumentoScreen(),
        );
      case ofertas:
        return MaterialPageRoute(
          builder: (_) => const OfertasScreen(initialTab: 0),
        );
      case alertas:
        return MaterialPageRoute(
          builder: (_) => const OfertasScreen(initialTab: 1),
        );
      case consentimiento:
        return MaterialPageRoute(
          builder: (_) => const ConsentimientoScreen(),
        );
      case resultadoBuro:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ResultadoBuroScreen(),
        );
      case preevaluacion:
        return MaterialPageRoute(
          builder: (_) => const PreEvaluacionScreen(),
        );
      case yapePlin:
        return MaterialPageRoute(
          builder: (_) => const YapePlinScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }
}
