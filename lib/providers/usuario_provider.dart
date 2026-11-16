import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _usuario;
  bool _cargando = false;
  String? _error;
  String? _token;

  UserProvider({required AuthService authService}) : _authService = authService;

  User? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaAutenticado => _usuario != null;

  void establecerUsuario(User usuario) {
    _usuario = usuario;
    _error = null;
    notifyListeners();
  }

  void actualizarUsuario(User usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void establecerCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }

  void establecerError(String? mensaje) {
    _error = mensaje;
    notifyListeners();
  }

  String? get token => _token;

  // Registrar un usuario.
  Future<bool> registrar(RegisterRequest request) async {
    _iniciarCarga();

    try {
      final respuesta = await _authService.registrar(datos: request.toJson());

      await _guardarSesion(respuesta);
      return true;
    } catch (e) {
      _error = _mensajeError(e);
      return false;
    } finally {
      _finalizarCarga();
    }
  }

  // Iniciar sesión.
  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    _iniciarCarga();

    try {
      final respuesta = await _authService.iniciarSesion(
        email: email,
        password: password,
      );

      await _guardarSesion(respuesta);
      return true;
    } catch (e) {
      _error = _mensajeError(e);
      return false;
    } finally {
      _finalizarCarga();
    }
  }

  // Consultar el usuario usando el token guardado.
  Future<bool> cargarUsuario() async {
    _iniciarCarga();

    try {
      final tokenGuardado = await _storage.read(key: 'auth_token');

      if (tokenGuardado == null || tokenGuardado.isEmpty) {
        _usuario = null;
        _token = null;
        return false;
      }

      final respuesta = await _authService.obtenerUsuario(token: tokenGuardado);

      final datosUsuario = respuesta['user'];

      if (datosUsuario is! Map<String, dynamic>) {
        throw const FormatException('La respuesta del usuario no es válida.');
      }

      _token = tokenGuardado;
      _usuario = User.fromJson(datosUsuario);

      return true;
    } catch (_) {
      _usuario = null;
      _token = null;
      await _storage.delete(key: 'auth_token');
      return false;
    } finally {
      _finalizarCarga();
    }
  }

  // Cerrar sesión.
  Future<void> cerrarSesion() async {
    _iniciarCarga();

    try {
      if (_token != null) {
        await _authService.cerrarSesion(token: _token!);
      }
    } catch (_) {
      // Si no hay conexión, igualmente limpiamos la sesión local.
    } finally {
      await _storage.delete(key: 'auth_token');
      _usuario = null;
      _token = null;
      _error = null;
      _finalizarCarga();
    }
  }

  // Guardar los datos de sesión recibidos desde Laravel.
  Future<void> _guardarSesion(Map<String, dynamic> respuesta) async {
    final datosUsuario = respuesta['user'];
    final tokenRecibido = respuesta['token'];

    if (datosUsuario is! Map<String, dynamic> ||
        tokenRecibido is! String ||
        tokenRecibido.isEmpty) {
      throw const FormatException(
        'Laravel no devolvió los datos de sesión esperados.',
      );
    }

    final nuevoUsuario = User.fromJson(datosUsuario);

    await _storage.write(key: 'auth_token', value: tokenRecibido);

    _usuario = nuevoUsuario;
    _token = tokenRecibido;
    _error = null;
  }

  void _iniciarCarga() {
    _cargando = true;
    _error = null;
    notifyListeners();
  }

  void _finalizarCarga() {
    _cargando = false;
    notifyListeners();
  }

  String _mensajeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
