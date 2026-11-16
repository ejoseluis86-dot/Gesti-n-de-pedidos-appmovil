import 'package:flutter/foundation.dart';
import '../models/item_carrito.dart';
import '../models/producto.dart';

class CarritoProvider extends ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => _items;

  void agregarProducto(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);

    if (index != -1) {
      _items[index].cantidad++;
    } else {
      _items.add(ItemCarrito(producto: producto));
    }

    notifyListeners();
  }

  void quitarProducto(int productoId) {
    final index = _items.indexWhere((item) => item.producto.id == productoId);

    if (index != -1) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  void eliminarProducto(int productoId) {
    _items.removeWhere((item) => item.producto.id == productoId);

    notifyListeners();
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }

  double get total {
    return _items.fold(0, (total, item) => total + item.subtotal);
  }

  int get cantidadProductos {
    return _items.fold(0, (total, item) => total + item.cantidad);
  }

  bool get estaVacio => _items.isEmpty;

  int cantidadDe(int id) {
    final index = _items.indexWhere((item) => item.producto.id == id);
    if (index != -1) {
      return _items[index].cantidad;
    }
    return 0;
  }
}
