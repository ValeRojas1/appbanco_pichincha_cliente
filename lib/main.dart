import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/navigation/app_router.dart';
import 'app/ui/theme/app_theme.dart';
import 'app/viewmodel/auth_viewmodel.dart';
import 'app/viewmodel/home_viewmodel.dart';

void main() {
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