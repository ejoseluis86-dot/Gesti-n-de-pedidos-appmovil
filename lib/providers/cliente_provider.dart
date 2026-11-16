import 'package:app_clientes/providers/usuario_provider.dart';
import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../services/cliente_service.dart';

class ClienteProvider extends ChangeNotifier {
  final ClienteService _clienteService;
  final UserProvider _usuarioProvider;

  ClienteProvider({
    required ClienteService clienteService,
    required UserProvider usuarioProvider,
  }) : _clienteService = clienteService,
       _usuarioProvider = usuarioProvider;

  List<Cliente> _clientes = [];
  Cliente? _miCliente;
  Cliente? _clienteSeleccionado;

  bool _cargando = false;
  String? _error;

  // Getters
  List<Cliente> get clientes => List.unmodifiable(_clientes);
  Cliente? get miCliente => _miCliente;
  Cliente? get clienteSeleccionado => _clienteSeleccionado;
  bool get cargando => _cargando;
  String? get error => _error;

  // Cargar todos los clientes: preventista
  Future<void> cargarClientes() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final token = _usuarioProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Iniciá sesión para consultar los clientes.');
      }

      _clientes = await _clienteService.obtenerClientes(token: token);
    } catch (e) {
      _error = 'Error al cargar los clientes: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarClienteSeleccionado(int id) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _clienteSeleccionado = _clientes.firstWhere(
        (cliente) => cliente.id == id,
      );
    } catch (e) {
      _error = 'Error al cargar el cliente seleccionado: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Cargar el cliente asociado al usuario autenticado
  Future<void> cargarMiCliente() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final token = _usuarioProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Iniciá sesión para consultar los clientes.');
      }
      _miCliente = await _clienteService.obtenerMiCliente(token: token);
    } catch (e) {
      _error = 'Error al cargar tu perfil de cliente: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Buscar un cliente por su ID
  Cliente? buscarPorId(int id) {
    for (final cliente in _clientes) {
      if (cliente.id == id) return cliente;
    }

    if (_miCliente?.id == id) return _miCliente;

    return null;
  }

  // Limpiar los datos al cerrar sesión
  void limpiar() {
    _clientes = [];
    _miCliente = null;
    _error = null;
    _cargando = false;
    notifyListeners();
  }
}
