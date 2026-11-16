class DetallePedidoRequest {
  final int cantidad;
  final double precioProducto;
  final double costoProducto;
  final int descuento;
  final double subtotal;
  final int productoId;

  DetallePedidoRequest({
    required this.cantidad,
    required this.precioProducto,
    required this.costoProducto,
    required this.descuento,
    required this.subtotal,
    required this.productoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'cantidad': cantidad,
      'precioProducto': precioProducto,
      'costoProducto': costoProducto,
      'descuento': descuento,
      'subtotal': subtotal,
      'producto_id': productoId,
    };
  }
}
