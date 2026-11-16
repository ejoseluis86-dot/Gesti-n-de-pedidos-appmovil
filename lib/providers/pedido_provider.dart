import 'package:flutter/material.dart';
import '../models/pedido_resumen.dart';
import '../services/pedido_service.dart';
import 'usuario_provider.dart';

class PedidosProvider extends ChangeNotifier {
  final PedidoService _pedidoService;
  final UserProvider _usuarioProvider;

  PedidosProvider({
    required PedidoService pedidoService,
    required UserProvider usuarioProvider,
  }) : _pedidoService = pedidoService,
       _usuarioProvider = usuarioProvider;

  DateTime? desde;
  DateTime? hasta;

  bool get hayFiltro => desde != null && hasta != null;

  // Pedidos dentro del rango (ambos extremos incluidos)
  List<PedidoResumen> get pedidosFiltrados {
    if (!hayFiltro) return pedidos;

    return pedidos.where((p) {
      final fecha = DateTime.parse(p.fecha);
      return !fecha.isBefore(desde!) && !fecha.isAfter(hasta!);
    }).toList();
  }

  void filtrarPorFechas(DateTime d, DateTime h) {
    desde = d;
    hasta = h;
    notifyListeners();
  }

  void limpiarFiltro() {
    desde = null;
    hasta = null;
    notifyListeners();
  } //hasta aca el filtro

  List<PedidoResumen> pedidos = [];
  bool cargando = false;
  String? error;

  Future<void> cargar() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final token = _usuarioProvider.token; // ajustá al nombre real
      if (token == null || token.isEmpty) {
        throw Exception('Iniciá sesión para consultar los clientes.');
      }
      pedidos = await _pedidoService.obtenerPedidos(token: token);
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void limpiar() {
    pedidos = [];
    error = null;
    desde = null; // <- nuevo
    hasta = null; // <- nuevo
    notifyListeners();
  }
}
