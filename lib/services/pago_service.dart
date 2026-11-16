import 'api_service.dart';

class PagoService {
  PagoService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  /// Pide a Laravel el link de pago de Mercado Pago para el pedido.
  Future<String> iniciarPago(int pedidoId, String token) async {
    final res = await _api.post('/pedidos/$pedidoId/pagar', token: token);
    final url = res['init_point'];
    if (url is! String || url.isEmpty) {
      throw Exception('El servidor no devolvió el link de pago.');
    }
    return url;
  }

  /// Consulta si el pedido ya figura pagado (lo marca el webhook en Laravel).
  Future<bool> estaPagado(int pedidoId, String token) async {
    final res = await _api.get('/pedidos', token: token);
    final lista = res['data'];
    if (lista is! List) return false;

    for (final p in lista) {
      if (p is Map && p['id'] == pedidoId) {
        return p['pagado'] == true || p['pagado'] == 1;
      }
    }
    return false;
  }
}
