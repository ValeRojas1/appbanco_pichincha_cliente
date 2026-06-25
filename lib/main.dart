import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/core/supabase_config.dart';
import 'app/navigation/app_router.dart';
import 'app/ui/theme/app_theme.dart';
import 'app/viewmodel/auth_viewmodel.dart';
import 'app/viewmodel/home_viewmodel.dart';
import 'app/viewmodel/cuenta_viewmodel.dart';
import 'app/viewmodel/pago_viewmodel.dart';
import 'app/viewmodel/ahorro_viewmodel.dart';
import 'app/viewmodel/credito_viewmodel.dart';
import 'app/viewmodel/solicitud_credito_viewmodel.dart';
import 'app/viewmodel/ofertas_viewmodel.dart';
import 'app/viewmodel/perfil_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  runApp(const AppPichinchaCliente());
}

class AppPichinchaCliente extends StatelessWidget {
  const AppPichinchaCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CuentaViewModel()),
        ChangeNotifierProvider(create: (_) => PagoViewModel()),
        ChangeNotifierProvider(create: (_) => AhorroViewModel()),
        ChangeNotifierProvider(create: (_) => CreditoViewModel()),
        ChangeNotifierProvider(create: (_) => SolicitudCreditoViewModel()),
        ChangeNotifierProvider(create: (_) => OfertasViewModel()),
        ChangeNotifierProvider(create: (_) => PerfilViewModel()),
      ],
      child: MaterialApp(
        title: 'Banco Pichincha Perú',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.temaCliente,
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
