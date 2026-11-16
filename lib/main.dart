import 'package:app_clientes/providers/carrito_provider.dart';
import 'package:app_clientes/providers/cliente_provider.dart';
import 'package:app_clientes/providers/pedido_provider.dart';
import 'package:app_clientes/providers/usuario_provider.dart';
import 'package:app_clientes/rutas/mis_rutas.dart';
import 'package:app_clientes/services/api_service.dart';
import 'package:app_clientes/services/auth_service.dart';
import 'package:app_clientes/services/cliente_service.dart';
import 'package:app_clientes/services/pedido_service.dart';
import 'package:app_clientes/services/producto_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/producto_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarritoProvider()),

        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),

        Provider<ProductoService>(
          create: (context) => ProductoService(context.read<ApiService>()),
        ),

        Provider<ClienteService>(
          create: (context) => ClienteService(context.read<ApiService>()),
        ),

        Provider<AuthService>(
          create: (context) => AuthService(context.read<ApiService>()),
        ),
        Provider<PedidoService>(
          create: (context) => PedidoService(context.read<ApiService>()),
        ),
        Provider<PedidoService>(
          create: (context) => PedidoService(context.read<ApiService>()),
        ),

        ChangeNotifierProvider<UserProvider>(
          create: (context) =>
              UserProvider(authService: context.read<AuthService>()),
        ),

        ChangeNotifierProvider<ProductosProvider>(
          create: (context) => ProductosProvider(
            productoService: context.read<ProductoService>(),
            usuarioProvider: context.read<UserProvider>(),
          ),
        ),

        ChangeNotifierProvider<ClienteProvider>(
          create: (context) => ClienteProvider(
            clienteService: context.read<ClienteService>(),
            usuarioProvider: context.read<UserProvider>(),
          ),
        ),

        ChangeNotifierProvider<PedidosProvider>(
          create: (context) => PedidosProvider(
            pedidoService: context.read<PedidoService>(),
            usuarioProvider: context.read<UserProvider>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Pedidos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      initialRoute: MisRutas.login,
      routes: MisRutas.rutas,
    );
  }
}
