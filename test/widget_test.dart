import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/auth_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/home_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/cuenta_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/pago_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/prestamo_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/ahorro_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/ui/theme/app_theme.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => HomeViewModel()),
          ChangeNotifierProvider(create: (_) => CuentaViewModel()),
          ChangeNotifierProvider(create: (_) => PagoViewModel()),
          ChangeNotifierProvider(create: (_) => PrestamoViewModel()),
          ChangeNotifierProvider(create: (_) => AhorroViewModel()),
        ],
        child: MaterialApp(
          home: const Scaffold(body: Center(child: Text('Banco Pichincha Perú'))),
          theme: AppTheme.temaCliente,
        ),
      ),
    );

    expect(find.text('Banco Pichincha Perú'), findsOneWidget);
  });
}
