import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class VisorDocumentoScreen extends StatelessWidget {
  const VisorDocumentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? titulo = args?['titulo'];
    final String? url = args?['url'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          titulo ?? 'Visor de Documento',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: url == null || url.isEmpty
            ? const Text(
                'No pudimos mostrar el documento.\nIntenta abrirlo de nuevo.',
                style: TextStyle(color: Colors.white70),
              )
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.amarillo),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Colors.white54, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'No pudimos cargar el documento.\nVerifica tu conexión e inténtalo de nuevo.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
