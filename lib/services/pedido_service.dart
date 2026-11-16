import 'package:app_clientes/models/pedido_resumen.dart';
import 'package:app_clientes/services/api_service.dart';
import '../models/pedido_request.dart'; // ajustá la ruta

class PedidoService {
  final ApiService _api;
  PedidoService(this._api);

  // Registra el pedido y devuelve lo que calculó el servidor (id y total).
  Future<Map<String, dynamic>> crearPedido({
    required String token,
    required PedidoRequest pedido,
  }) async {
    final respuesta = await _api.post(
      'pedidos',
      body: pedido.toJson(),
      token: token,
    );

    final dynamic datos = respuesta['data'];

    if (datos is! Map) {
      throw Exception('La API no devolvió el pedido creado.');
    }

    return Map<String, dynamic>.from(datos);
  }

  // Pedidos del usuario: los suyos si es cliente, los que registró si es preventista.
  Future<List<PedidoResumen>> obtenerPedidos({required String token}) async {
    final respuesta = await _api.get('pedidos', token: token);

    final dynamic datos = respuesta['data'];

    if (datos is! List) {
      throw Exception('La API no devolvió una lista válida de pedidos.');
    }

    return datos
        .map((item) => PedidoResumen.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
