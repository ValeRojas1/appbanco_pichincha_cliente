import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../ui/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _dniController = TextEditingController();
  final _passController = TextEditingController();
  bool _verPassword = false;

  @override
  void dispose() {
    _dniController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grisClaro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Consumer<AuthViewModel>(
            builder: (context, vm, _) {
              if (vm.state == AuthState.success) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  vm.reset();
                  Navigator.pushReplacementNamed(context, '/dashboard');
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _LogoPichincha(),
                  const SizedBox(height: 12),
                  Text(
                    'Banco Pichincha Perú',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Banca Personal',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.grisMedio,
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      labelText: 'DNI',
                      hintText: 'Ingresa tu número de DNI',
                      prefixIcon: Icon(Icons.badge_outlined),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    obscureText: !_verPassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _verPassword = !_verPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (vm.state == AuthState.error)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.rojoError.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.rojoError.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppTheme.rojoError, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            vm.errorMessage,
                            style: TextStyle(
                                color: AppTheme.rojoError, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  vm.state == AuthState.loading
                      ? const CircularProgressIndicator(
                          color: AppTheme.navy,
                        )
                      : ElevatedButton(
                          onPressed: () => vm.login(
                            _dniController.text.trim(),
                            _passController.text.trim(),
                          ),
                          child: const Text('INGRESAR'),
                        ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.navy.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Demo — DNI: 47201831 | Pass: 4720',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.grisMedio),
                      textAlign: TextAlign.center,
                    ),
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

class _LogoPichincha extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              width: 16,
              height: 44,
              color: AppTheme.amarillo,
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              width: 36,
              height: 16,
              color: AppTheme.amarillo,
            ),
          ),
        ],
      ),
    );
  }
}
