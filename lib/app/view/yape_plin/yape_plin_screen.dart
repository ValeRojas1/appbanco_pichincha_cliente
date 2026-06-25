import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../../viewmodel/cuenta_viewmodel.dart';
import '../../model/cuenta_model.dart';
import '../../ui/theme/app_theme.dart';

class YapePlinScreen extends StatefulWidget {
  const YapePlinScreen({super.key});

  @override
  State<YapePlinScreen> createState() => _YapePlinScreenState();
}

class _YapePlinScreenState extends State<YapePlinScreen> {
  bool _isYape = true; // true = Yape, false = Plin

  // Controllers and State for Yape
  final _telefonoCtrlYape = TextEditingController();
  final _montoCtrlYape = TextEditingController();
  final _notaCtrlYape = TextEditingController();
  String _destinatarioYape = '';

  // Controllers and State for Plin
  final _telefonoCtrlPlin = TextEditingController();
  final _montoCtrlPlin = TextEditingController();
  final _notaCtrlPlin = TextEditingController();
  String _destinatarioPlin = '';

  // Active Getters/Setters dynamically evaluated
  TextEditingController get _telefonoCtrl => _isYape ? _telefonoCtrlYape : _telefonoCtrlPlin;
  TextEditingController get _montoCtrl => _isYape ? _montoCtrlYape : _montoCtrlPlin;
  TextEditingController get _notaCtrl => _isYape ? _notaCtrlYape : _notaCtrlPlin;

  String get _destinatario => _isYape ? _destinatarioYape : _destinatarioPlin;
  set _destinatario(String val) {
    if (_isYape) {
      _destinatarioYape = val;
    } else {
      _destinatarioPlin = val;
    }
  }

  final _focusNodeTelefono = FocusNode();
  final _focusNodeMonto = FocusNode();

  bool _buscando = false;
  bool _realizandoPago = false;
  String? _errorMensaje;

  // Datos para el recibo de éxito
  bool _pagoExitoso = false;
  String _reciboMonto = '';
  String _reciboDestinatario = '';
  String _reciboTelefono = '';
  String _reciboFecha = '';
  String _reciboId = '';

  // Colores para Yape y Plin
  static const Color yapePurple = Color(0xFF5F259F);
  static const Color plinTeal = Color(0xFF00BAC5);

  Color get _walletColor => _isYape ? yapePurple : plinTeal;
  String get _walletName => _isYape ? 'Yape' : 'Plin';

  @override
  void initState() {
    super.initState();
    _telefonoCtrlYape.addListener(_onTelefonoChanged);
    _telefonoCtrlPlin.addListener(_onTelefonoChanged);
  }

  @override
  void dispose() {
    _telefonoCtrlYape.removeListener(_onTelefonoChanged);
    _telefonoCtrlPlin.removeListener(_onTelefonoChanged);
    _telefonoCtrlYape.dispose();
    _telefonoCtrlPlin.dispose();
    _montoCtrlYape.dispose();
    _montoCtrlPlin.dispose();
    _notaCtrlYape.dispose();
    _notaCtrlPlin.dispose();
    _focusNodeTelefono.dispose();
    _focusNodeMonto.dispose();
    super.dispose();
  }

  void _onTelefonoChanged() async {
    final tel = _telefonoCtrl.text.trim();
    if (tel.length == 9) {
      setState(() {
        _buscando = true;
        _destinatario = '';
        _errorMensaje = null;
      });
      final cuentaVm = Provider.of<CuentaViewModel>(context, listen: false);
      final nombre = await cuentaVm.buscarDestinatario(tel);
      setState(() {
        _buscando = false;
        if (nombre != null) {
          _destinatario = nombre;
        } else {
          _destinatario = _generarNombreSimulado(tel);
        }
      });
    } else {
      if (_destinatario.isNotEmpty) {
        setState(() {
          _destinatario = '';
        });
      }
    }
  }

  String _generarNombreSimulado(String tel) {
    final digito = int.tryParse(tel.substring(tel.length - 1)) ?? 0;
    final nombres = [
      'Juan Quispe', 'María Alva', 'Carlos Mendoza', 'Ana Flores',
      'Pedro Ccanto', 'Rosa Mamani', 'José Sandoval', 'Lucía Paredes',
      'Gabriel Ortiz', 'Sofía Castillo'
    ];
    return nombres[digito % nombres.length];
  }

  void _seleccionarMontoRapido(double monto) {
    setState(() {
      _montoCtrl.text = monto.toStringAsFixed(0);
    });
  }

  Future<void> _procesarEnvio(CuentaModel cuentaAhorros, String clienteId) async {
    final tel = _telefonoCtrl.text.trim();
    final montoStr = _montoCtrl.text.trim();
    final monto = double.tryParse(montoStr) ?? 0.0;
    final nota = _notaCtrl.text.trim();

    if (tel.length != 9 || !tel.startsWith('9')) {
      setState(() {
        _errorMensaje = 'Ingresa un número celular válido de 9 dígitos que inicie con 9.';
      });
      return;
    }

    if (monto <= 0) {
      setState(() {
        _errorMensaje = 'Ingresa un monto válido mayor a 0.';
      });
      return;
    }

    if (monto > cuentaAhorros.saldo) {
      setState(() {
        _errorMensaje = 'Saldo insuficiente en tu Cuenta de Ahorros.';
      });
      return;
    }

    setState(() {
      _realizandoPago = true;
      _errorMensaje = null;
    });

    final desc = 'Pago $_walletName a $_destinatario${nota.isNotEmpty ? ' - $nota' : ''}';
    final cuentaVm = Provider.of<CuentaViewModel>(context, listen: false);

    final ok = await cuentaVm.realizarPagoYapePlin(
      userid: clienteId,
      cuentaid: cuentaAhorros.cuentaid,
      montoActual: cuentaAhorros.saldo,
      montoDescontar: monto,
      descripcion: desc,
    );

    if (ok) {
      if (!mounted) return;
      // Recargar saldo en el dashboard
      Provider.of<HomeViewModel>(context, listen: false).recargar();

      final now = DateTime.now();
      final rnd = Random();
      final idTxn = 'OP${100000 + rnd.nextInt(900000)}';

      setState(() {
        _realizandoPago = false;
        _pagoExitoso = true;
        _reciboMonto = 'S/ ${monto.toStringAsFixed(2)}';
        _reciboDestinatario = _destinatario;
        _reciboTelefono = tel;
        _reciboFecha = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        _reciboId = idTxn;
      });
    } else {
      setState(() {
        _realizandoPago = false;
        _errorMensaje = cuentaVm.error ?? 'Hubo un error al procesar el pago. Inténtalo de nuevo.';
      });
    }
  }

  void _compartirConstancia() {
    final text = 'Constancia de pago $_walletName\n'
        'Monto: $_reciboMonto\n'
        'Destinatario: $_reciboDestinatario\n'
        'Teléfono: $_reciboTelefono\n'
        'Fecha: $_reciboFecha\n'
        'Código de Operación: $_reciboId\n'
        'Enviado desde mi App Banco Pichincha';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Constancia copiada al portapapeles para compartir.'),
          ],
        ),
        backgroundColor: _walletColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = Provider.of<HomeViewModel>(context);
    final cuentaAhorros = homeVm.cuentaAhorrosCuenta;
    final cliente = homeVm.cliente;

    if (_pagoExitoso) {
      return _buildReceiptView();
    }

    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      appBar: AppBar(
        title: Text('Enviar por $_walletName'),
        backgroundColor: _walletColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Wallet Switcher Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _walletColor.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: _walletColor.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WalletTab(
                    label: 'YAPE',
                    activeColor: yapePurple,
                    isActive: _isYape,
                    onTap: () {
                      if (!_realizandoPago) {
                        setState(() {
                          _isYape = true;
                          _errorMensaje = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  _WalletTab(
                    label: 'PLIN',
                    activeColor: plinTeal,
                    isActive: !_isYape,
                    onTap: () {
                      if (!_realizandoPago) {
                        setState(() {
                          _isYape = false;
                          _errorMensaje = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            if (cuentaAhorros == null)
              // Error view: No savings account
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppTheme.rojoError),
                    const SizedBox(height: 16),
                    const Text(
                      'Operación No Disponible',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navy),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lo sentimos, los pagos de Yape y Plin solo están disponibles si cuentas con una Cuenta de Ahorros activa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.grisMedio),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navy,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver al Inicio'),
                    )
                  ],
                ),
              )
            else
              // Main content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cuenta origen card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _walletColor.withValues(alpha: 0.1),
                            child: Icon(Icons.account_balance_wallet, color: _walletColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cuenta de Origen',
                                  style: TextStyle(fontSize: 11, color: AppTheme.grisMedio),
                                ),
                                Text(
                                  'Cuenta de Ahorros (${cuentaAhorros.numerocuenta})',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.navy),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Saldo: S/ ${cuentaAhorros.saldo.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.verdeSaldo),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Destinatario
                    const Text(
                      '¿A quién deseas enviar?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navy),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _telefonoCtrl,
                      focusNode: _focusNodeTelefono,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 9,
                      enabled: !_realizandoPago,
                      decoration: InputDecoration(
                        labelText: 'Número de celular',
                        prefixIcon: const Icon(Icons.phone_android),
                        counterText: '',
                        suffixIcon: _buscando
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navy),
                                ),
                              )
                            : null,
                      ),
                    ),

                    // Result of contact search
                    if (_destinatario.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.verdeSaldo.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.verdeSaldo.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppTheme.verdeSaldo, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Destinatario: $_destinatario',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.verdeSaldo, fontSize: 13),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Monto
                    const Text(
                      '¿Cuánto deseas enviar?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navy),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _montoCtrl,
                      focusNode: _focusNodeMonto,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: !_realizandoPago,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.navy),
                      decoration: InputDecoration(
                        labelText: 'Monto (S/)',
                        prefixIcon: Icon(Icons.attach_money, color: _walletColor),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Montos rápidos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [5.0, 10.0, 20.0, 50.0, 100.0].map((m) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: _realizandoPago ? null : () => _seleccionarMontoRapido(m),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppTheme.grisMedio.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'S/ ${m.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _walletColor),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Nota opcional
                    const Text(
                      'Mensaje (Opcional)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.navy),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notaCtrl,
                      enabled: !_realizandoPago,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        labelText: '¿Para qué es?',
                        prefixIcon: Icon(Icons.edit_note),
                        counterText: '',
                      ),
                    ),

                    // Mensaje de Error
                    if (_errorMensaje != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.rojoError.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.rojoError.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.rojoError),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMensaje!,
                                style: const TextStyle(color: AppTheme.rojoError, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Enviar Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _walletColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _walletColor.withValues(alpha: 0.5),
                        ),
                        onPressed: (_realizandoPago || _destinatario.isEmpty)
                            ? null
                            : () => _procesarEnvio(cuentaAhorros, cliente!.id),
                        child: _realizandoPago
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Enviar por $_walletName'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Recibo de Éxito
  Widget _buildReceiptView() {
    return Scaffold(
      backgroundColor: _walletColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Celebración emojis
              const Text(
                '🎉 ¡Envío Exitoso! 🎊',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Contenedor del recibo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Círculo del check
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Color(0xFF2E7D32), size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Dinero enviado!',
                      style: TextStyle(color: AppTheme.grisMedio, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _reciboMonto,
                      style: TextStyle(color: _walletColor, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 32, thickness: 1),

                    // Detalles del envío
                    _buildReceiptRow('Destinatario', _reciboDestinatario, isBold: true),
                    const SizedBox(height: 12),
                    _buildReceiptRow('Celular', _reciboTelefono),
                    const SizedBox(height: 12),
                    _buildReceiptRow('Billetera', _walletName),
                    const SizedBox(height: 12),
                    _buildReceiptRow('Fecha', _reciboFecha),
                    const SizedBox(height: 12),
                    _buildReceiptRow('Código Op.', _reciboId),
                  ],
                ),
              ),
              const Spacer(),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _compartirConstancia,
                      icon: const Icon(Icons.share, size: 20),
                      label: const Text('Compartir', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _walletColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Ir al Inicio'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.grisMedio, fontSize: 13)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: AppTheme.navy,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletTab extends StatelessWidget {
  final String label;
  final Color activeColor;
  final bool isActive;
  final VoidCallback onTap;

  const _WalletTab({
    required this.label,
    required this.activeColor,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : AppTheme.grisMedio.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.grisMedio,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
