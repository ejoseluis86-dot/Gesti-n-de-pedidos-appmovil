import 'package:app_clientes/screens/clientes_dias_screen.dart';
import 'package:app_clientes/screens/crearusuario_screen.dart';
import 'package:app_clientes/screens/homepage_screen.dart';
import 'package:app_clientes/screens/loginpage_screen.dart';
import 'package:app_clientes/screens/usuariopage_screen.dart';
import 'package:flutter/material.dart';

class MisRutas {
  static const String home = '/';
  static const String login = '/login';
  static const String usuario = '/usuario';
  static const String createUsuario = '/createusuario';
  static const String clientes = '/clientes';

  static final Map<String, WidgetBuilder> rutas = {
    home: (context) => const HomePage(),
    login: (context) => const LoginScreen(),
    usuario: (context) => const PedidosScreen(),
    createUsuario: (context) => const CrearUsuarioScreen(),
    clientes: (context) => const ClientesDiaScreen(),
  };
}
