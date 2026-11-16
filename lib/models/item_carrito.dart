import 'producto.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get subtotal {
    return (producto.precio * (1 - producto.descuento / 100)) * cantidad;
  }
}
