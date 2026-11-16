import 'api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService(this._api);

  // Registrar un usuario.
  Future<Map<String, dynamic>> registrar({
    required Map<String, dynamic> datos,
  }) {
    return _api.post('register', body: datos);
  }

  // Iniciar sesión.
  Future<Map<String, dynamic>> iniciarSesion({
    required String email,
    required String password,
  }) {
    return _api.post(
      'login',
      body: {'email': email.trim(), 'password': password},
    );
  }

  // Obtener los datos del usuario autenticado.
  Future<Map<String, dynamic>> obtenerUsuario({required String token}) {
    return _api.get('user', token: token);
  }

  // Cerrar sesión en Laravel.
  Future<Map<String, dynamic>> cerrarSesion({required String token}) {
    return _api.post('logout', token: token);
  }
}
