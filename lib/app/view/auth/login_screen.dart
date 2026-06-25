import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/auth_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/home_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/ui/theme/app_theme.dart';
import 'package:appbanco_pichincha_cliente/app/ui/widgets/pichincha_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _dniController = TextEditingController();
  final _passController = TextEditingController();
  bool _verPassword = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _dniController.dispose();
    _passController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final dni = _dniController.text.trim();
    final pass = _passController.text.trim();
    if (dni.length < 8 || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa tu DNI de 8 dígitos y tu contraseña para continuar.',
          ),
        ),
      );
      return;
    }
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final homeVm = Provider.of<HomeViewModel>(context, listen: false);
    final ok = await authVm.login(dni, pass);
    if (ok && mounted) {
      homeVm.init(authVm.cliente!);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navy,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.navyOscuro, AppTheme.navy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Logo
                  const PichinchaLogoHeader(
                    symbolSize: 75,
                    showSubtitle: true,
                  ),
                  const SizedBox(height: 44),
                  // Card login
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Error banner
                        Consumer<AuthViewModel>(
                          builder: (_, vm, __) {
                            if (vm.errorMessage == null) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.rojoError.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.rojoError.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.rojoError,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      vm.errorMessage!,
                                      style: const TextStyle(
                                        color: AppTheme.rojoError,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        TextField(
                          controller: _dniController,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          decoration: const InputDecoration(
                            labelText: 'Número de DNI',
                            prefixIcon: Icon(Icons.badge_outlined),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passController,
                          obscureText: !_verPassword,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.grisMedio,
                              ),
                              onPressed: () =>
                                  setState(() => _verPassword = !_verPassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<AuthViewModel>(
                          builder: (_, vm, __) => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: vm.isLoading ? null : _login,
                              child: vm.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.navy,
                                      ),
                                    )
                                  : const Text('Ingresar a mi cuenta'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/registro'),
                            child: const Text(
                              '¿No tienes cuenta? Regístrate aquí',
                              style: TextStyle(
                                color: AppTheme.navy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Demo credentials
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.amarillo.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.amarillo,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Credenciales demo',
                              style: TextStyle(
                                color: AppTheme.amarillo,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _demoRow(
                          'Rosa Mamani',
                          '45219837',
                          '123456',
                          'Cta. corriente + ahorro · 3 créditos activos',
                        ),
                        const SizedBox(height: 4),
                        _demoRow(
                          'Pedro Ccanto',
                          '78123456',
                          '123456',
                          'Cta. corriente + ahorro · 2 créditos (1 moroso)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoRow(String nombre, String dni, String pass, String productos) {
    return GestureDetector(
      onTap: () {
        _dniController.text = dni;
        _passController.text = pass;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  nombre,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '$dni / $pass',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              productos,
              style: TextStyle(
                color: AppTheme.amarillo.withValues(alpha: 0.75),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
