import 'detalle_pedido_request.dart';

class PedidoRequest {
  final String fecha;
  final String nota;
  final String cliente;
  final String direccion;
  final double total;
  final int usuarioId;
  final int clienteId;
  final List<DetallePedidoRequest> detalles;

  PedidoRequest({
    required this.fecha,
    required this.nota,
    required this.cliente,
    required this.direccion,
    required this.total,
    required this.usuarioId,
    required this.clienteId,
    required this.detalles,
  });

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'nota': nota,
      'cliente': cliente,
      'direccion': direccion,
      'total': total,
      'usuario_id': usuarioId,
      'cliente_id': clienteId,
      'detalles': detalles.map((d) => d.toJson()).toList(),
    };
  }
}
