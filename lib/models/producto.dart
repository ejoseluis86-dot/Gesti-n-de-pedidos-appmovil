class Producto {
  final int id;
  final String nombre;
  final double precio;
  final String imagen;
  final int stock;
  final int descuento;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.stock,
    required this.descuento,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre']?.toString() ?? '',
      precio: double.parse(json['precio'].toString()),
      imagen: json['imagen']?.toString() ?? '',
      stock: int.parse(json['stock'].toString()),
      descuento: int.tryParse((json['descuento'] ?? 0).toString()) ?? 0,
    );
  }

  double get precioFinal => precio * (1 - descuento / 100);

  double get ahorro => precio - precioFinal;
}
