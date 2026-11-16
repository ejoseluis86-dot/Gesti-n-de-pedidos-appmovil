class RegisterRequest {
  final String nombre;
  final String direccion;
  final String email;
  final String celular;
  final String password;
  final String passwordConfirmation;

  RegisterRequest({
    required this.nombre,
    required this.direccion,
    required this.email,
    required this.celular,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'email': email,
      'celular': celular,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
