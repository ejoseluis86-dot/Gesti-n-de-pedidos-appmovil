class PedidoResumen {
  final int id;
  final String fecha;
  final String nota;
  final String cliente;
  final String direccion;
  final double total;
  final bool pagado;

  PedidoResumen({
    required this.id,
    required this.fecha,
    required this.nota,
    required this.cliente,
    required this.direccion,
    required this.total,
    required this.pagado,
  });

  factory PedidoResumen.fromJson(Map<String, dynamic> json) {
    return PedidoResumen(
      id: json['id'] as int,
      fecha: json['fecha'].toString().substring(0, 10),
      nota: (json['nota'] ?? '').toString(),
      cliente: (json['cliente'] ?? '').toString(),
      direccion: (json['direccion'] ?? '').toString(),
      total: double.parse(json['total'].toString()),
      pagado: json['pagado'] == true || json['pagado'] == 1,
    );
  }

  String get fechaFormateada => fecha.split('-').reversed.join('/');
}
