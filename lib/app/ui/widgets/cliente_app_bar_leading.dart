import 'package:flutter/material.dart';
import 'cliente_bottom_nav_bar.dart';

/// Botón atrás / inicio para pantallas secundarias del cliente.
class ClienteAppBarLeading extends StatelessWidget {
  const ClienteAppBarLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Volver',
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          irAlInicioCliente(context);
        }
      },
    );
  }
}
