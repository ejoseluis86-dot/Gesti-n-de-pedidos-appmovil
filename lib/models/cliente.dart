class Cliente {
  final int? id;
  final String nombre;
  final String direccion;
  final String email;
  final String dia;
  final String celular;
  final int userId;

  Cliente({
    this.id,
    required this.nombre,
    required this.direccion,
    required this.email,
    required this.dia,
    required this.celular,
    required this.userId,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      email: json['email'],
      dia: json['dia'],
      celular: json['celular'],
      userId: json['user_id'],
    );
  }
}
