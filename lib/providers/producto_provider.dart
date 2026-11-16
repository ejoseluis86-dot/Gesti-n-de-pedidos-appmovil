import 'package:flutter/foundation.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';
import 'usuario_provider.dart';

class ProductosProvider extends ChangeNotifier {
  final ProductoService _productoService;
  final UserProvider _usuarioProvider;

  ProductosProvider({
    required ProductoService productoService,
    required UserProvider usuarioProvider,
  }) : _productoService = productoService,
       _usuarioProvider = usuarioProvider;

  List<Producto> _productos = [];
  bool _cargando = false;
  String? _error;

  List<Producto> get productos => _productos;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarProductos() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      // Obtener el token de la sesión actual.
      final token = _usuarioProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Iniciá sesión para consultar los productos.');
      }

      _productos = await _productoService.obtenerProductos(token: token);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  List<Producto> buscarProductos(String texto) {
    if (texto.trim().isEmpty) return _productos;

    final consulta = texto.trim().toLowerCase();

    return _productos.where((producto) {
      return producto.nombre.toLowerCase().contains(consulta);
    }).toList();
  }

  Producto? buscarPorId(int id) {
    for (final producto in _productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }

  void limpiarProductos() {
    _productos = [];
    notifyListeners();
  }
}
