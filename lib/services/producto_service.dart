import '../models/producto.dart';
import 'api_service.dart';

class ProductoService {
  final ApiService _api;

  ProductoService(this._api);

  Future<List<Producto>> obtenerProductos({required String token}) async {
    final respuesta = await _api.get('productos', token: token);

    final dynamic datos = respuesta['data'] ?? respuesta['productos'];

    if (datos is! List) {
      throw Exception('La API no devolvió una lista válida de productos.');
    }

    return datos.map((item) {
      final productoJson = Map<String, dynamic>.from(item);

      final imagen = productoJson['imagen']?.toString();

      if (imagen != null && imagen.isNotEmpty) {
        productoJson['imagen'] = _resolverUrlImagen(imagen);
      }

      return Producto.fromJson(productoJson);
    }).toList();
  }

  String _resolverUrlImagen(String imagen) {
    if (imagen.startsWith('http://') || imagen.startsWith('https://')) {
      return imagen;
    }

    final servidor = ApiService.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

    var ruta = imagen.startsWith('/') ? imagen.substring(1) : imagen;

    // Evitar agregar storage dos veces.
    if (!ruta.startsWith('storage/')) {
      ruta = 'storage/$ruta';
    }

    return '$servidor/$ruta';
  }
}
