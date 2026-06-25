import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:appbanco_pichincha_cliente/app/core/auth_validators.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/auth_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/viewmodel/home_viewmodel.dart';
import 'package:appbanco_pichincha_cliente/app/ui/theme/app_theme.dart';
import 'package:appbanco_pichincha_cliente/app/ui/widgets/pichincha_logo.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _dniController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _verPassword = false;
  bool _verConfirmPassword = false;
  bool _aceptaTerminos = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).reset();
    });
  }

  @override
  void dispose() {
    _correoController.dispose();
    _dniController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los términos y condiciones para continuar.',
          ),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Revisa los campos marcados en rojo antes de continuar.',
          ),
        ),
      );
      return;
    }

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final homeVm = Provider.of<HomeViewModel>(context, listen: false);

    final ok = await authVm.registrar(
      correo: _correoController.text.trim(),
      dni: _dniController.text.trim(),
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      telefono: _telefonoController.text.trim(),
      password: _passController.text,
    );

    if (!mounted) return;

    if (authVm.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.successMessage!),
          backgroundColor: AppTheme.verdeSaldo,
        ),
      );
    }

    if (ok) {
      homeVm.init(authVm.cliente!);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (authVm.successMessage != null) {
      Navigator.pop(context);
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        const PichinchaLogoHeader(
                          symbolSize: 60,
                          showSubtitle: false,
                        ),
                        const SizedBox(height: 24),
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Regístrate',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.navy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Completa tus datos para abrir tu cuenta digital.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.grisMedio,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildMensajes(),
                                TextFormField(
                                  controller: _correoController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico',
                                    prefixIcon: Icon(Icons.email_outlined),
                                    hintText: 'ejemplo@correo.com',
                                  ),
                                  validator: AuthValidators.validarCorreo,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _dniController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  maxLength: 8,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Número de DNI',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                    counterText: '',
                                    hintText: '8 dígitos',
                                  ),
                                  validator: AuthValidators.validarDni,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _nombresController,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombres',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: AuthValidators.validarNombres,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _apellidosController,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Apellidos',
                                    prefixIcon:
                                        Icon(Icons.person_outline),
                                  ),
                                  validator: AuthValidators.validarApellidos,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _telefonoController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  maxLength: 9,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Celular',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                    counterText: '',
                                    hintText: '9XXXXXXXX',
                                  ),
                                  validator: AuthValidators.validarTelefono,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passController,
                                  obscureText: !_verPassword,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  maxLength: 20,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña numérica',
                                    prefixIcon:
                                        const Icon(Icons.lock_outline),
                                    counterText: '',
                                    hintText: 'Mínimo 6 dígitos',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _verPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppTheme.grisMedio,
                                      ),
                                      onPressed: () => setState(
                                        () => _verPassword = !_verPassword,
                                      ),
                                    ),
                                  ),
                                  validator: AuthValidators.validarPassword,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPassController,
                                  obscureText: !_verConfirmPassword,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  maxLength: 20,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar contraseña',
                                    prefixIcon:
                                        const Icon(Icons.lock_outline),
                                    counterText: '',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _verConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppTheme.grisMedio,
                                      ),
                                      onPressed: () => setState(
                                        () => _verConfirmPassword =
                                            !_verConfirmPassword,
                                      ),
                                    ),
                                  ),
                                  validator: (v) =>
                                      AuthValidators.validarConfirmarPassword(
                                    v,
                                    _passController.text,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _aceptaTerminos,
                                        activeColor: AppTheme.navy,
                                        onChanged: (v) => setState(
                                          () => _aceptaTerminos = v ?? false,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => _aceptaTerminos =
                                              !_aceptaTerminos,
                                        ),
                                        child: const Text(
                                          'Acepto los términos y condiciones y la política de privacidad del Banco Pichincha.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.grisMedio,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Consumer<AuthViewModel>(
                                  builder: (_, vm, __) => SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          vm.isLoading ? null : _registrar,
                                      child: vm.isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppTheme.navy,
                                              ),
                                            )
                                          : const Text('Crear mi cuenta'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      '¿Ya tienes cuenta? Inicia sesión',
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
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMensajes() {
    return Consumer<AuthViewModel>(
      builder: (_, vm, __) {
        if (vm.errorMessage == null) return const SizedBox.shrink();
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
    );
  }
}
