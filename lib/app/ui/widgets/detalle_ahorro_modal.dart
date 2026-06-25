import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/cuenta_model.dart';
import '../../model/cliente_model.dart';
import '../../ui/theme/app_theme.dart';

class DetalleAhorroModal {
  static String formatCCI(String numerocuenta) {
    if (numerocuenta.replaceAll('-', '').length == 20) return numerocuenta;
    final clean = numerocuenta.replaceAll('-', '');
    final padded = clean.padLeft(12, '0');
    final control = ((padded.hashCode % 90) + 10).toString();
    return '011-123-$padded-$control';
  }

  static void mostrar(BuildContext context, CuentaModel cuenta, ClienteModel cliente, List<CuentaModel> todasCuentas) {
    final tieneSoles = todasCuentas.any((c) => c.moneda == 'PEN' && c.tipocuenta == 'ahorro');
    final tieneDolares = todasCuentas.any((c) => c.moneda == 'USD' && c.tipocuenta == 'ahorro');
    String tipoMoneda = 'Soles';
    if (tieneSoles && tieneDolares) {
      tipoMoneda = 'Ambos (Soles y Dólares)';
    } else if (cuenta.moneda == 'USD') {
      tipoMoneda = 'Dólares';
    }

    final cci = formatCCI(cuenta.numerocuenta ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.grisMedio.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalles de tu Cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.navy),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailItem('Titular de la cuenta', cliente.nombreCompleto),
              _buildDetailItem('DNI del titular', cliente.documento),
              _buildDetailItem('Tipo de cuenta', 'Ahorros - $tipoMoneda'),
              _buildDetailItem('Número de cuenta', cuenta.numerocuenta ?? 'No disponible'),
              _buildDetailItem('CCI (Interbancario)', cci),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.navy,
                        side: const BorderSide(color: AppTheme.navy, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final textToShare = 'Datos de mi cuenta Banco Pichincha:\n'
                            'Titular: ${cliente.nombreCompleto}\n'
                            'DNI: ${cliente.documento}\n'
                            'Banco: Pichincha\n'
                            'Cuenta: ${cuenta.numerocuenta}\n'
                            'CCI: $cci';
                        Clipboard.setData(ClipboardData(text: textToShare));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Datos de cuenta copiados. ¡Listos para compartir!'),
                              ],
                            ),
                            backgroundColor: AppTheme.navy,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartir datos', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.grisMedio,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
        ],
      ),
    );
  }
}
