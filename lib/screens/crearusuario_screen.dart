import 'package:app_clientes/models/register_request.dart';
import 'package:flutter/material.dart';

import 'package:app_clientes/providers/usuario_provider.dart';
import 'package:provider/provider.dart';

class CrearUsuarioScreen extends StatefulWidget {
  const CrearUsuarioScreen({super.key});

  @override
  State<CrearUsuarioScreen> createState() => _CrearUsuarioScreenState();
}

class _CrearUsuarioScreenState extends State<CrearUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _celularController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _mostrarPassword = false;
  bool _mostrarConfirmacion = false;
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _celularController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  String? _validarCampo(String? valor, String nombre) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresá $nombre';
    }
    return null;
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final request = RegisterRequest(
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        email: _emailController.text.trim(),
        celular: _celularController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmarPasswordController.text,
      );

      final provider = context.read<UserProvider>();
      final correcto = await provider.registrar(request);

      if (!mounted) return;

      if (correcto) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada correctamente!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'No se pudo crear la cuenta.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ocurrió un error: $e')));
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const rosa = Color(0xFFE91E63);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF333333),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0xFFFCE4EC),
                      child: Icon(
                        Icons.person_add_alt_1,
                        size: 38,
                        color: rosa,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '¡Creá tu cuenta!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completá tus datos para comenzar a realizar pedidos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    _campo(
                      controller: _nombreController,
                      etiqueta: 'Nombre completo',
                      icono: Icons.person_outline,
                      validator: (v) => _validarCampo(v, 'tu nombre'),
                    ),
                    const SizedBox(height: 16),

                    _campo(
                      controller: _emailController,
                      etiqueta: 'Correo electrónico',
                      icono: Icons.email_outlined,
                      tipo: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresá tu correo electrónico';
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(v.trim())) {
                          return 'Ingresá un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _campo(
                      controller: _direccionController,
                      etiqueta: 'Dirección de entrega',
                      icono: Icons.location_on_outlined,
                      validator: (v) => _validarCampo(v, 'tu dirección'),
                    ),
                    const SizedBox(height: 16),

                    _campo(
                      controller: _celularController,
                      etiqueta: 'Número de celular',
                      icono: Icons.phone_outlined,
                      tipo: TextInputType.phone,
                      validator: (v) => _validarCampo(v, 'tu celular'),
                    ),

                    const SizedBox(height: 16),

                    _campo(
                      controller: _passwordController,
                      etiqueta: 'Contraseña',
                      icono: Icons.lock_outline,
                      oculto: !_mostrarPassword,
                      sufijo: IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarPassword = !_mostrarPassword;
                          });
                        },
                        icon: Icon(
                          _mostrarPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresá una contraseña';
                        }
                        if (v.length < 8) {
                          return 'Usá al menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _campo(
                      controller: _confirmarPasswordController,
                      etiqueta: 'Confirmar contraseña',
                      icono: Icons.lock_reset_outlined,
                      oculto: !_mostrarConfirmacion,
                      sufijo: IconButton(
                        onPressed: () {
                          setState(() {
                            _mostrarConfirmacion = !_mostrarConfirmacion;
                          });
                        },
                        icon: Icon(
                          _mostrarConfirmacion
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirmá tu contraseña';
                        }
                        if (v != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 26),

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _cargando ? null : _registrar,
                        style: FilledButton.styleFrom(
                          backgroundColor: rosa,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _cargando
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '¿Ya tenés cuenta? Iniciá sesión',
                        style: TextStyle(color: rosa),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    TextInputType? tipo,
    bool oculto = false,
    Widget? sufijo,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      obscureText: oculto,
      validator: validator,
      decoration: _decoracion(etiqueta, icono).copyWith(suffixIcon: sufijo),
    );
  }

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE91E63), width: 1.5),
      ),
    );
  }
}
