import 'package:app_clientes/services/api_service.dart';
import '../models/cliente.dart';

class ClienteService {
  final ApiService _api;
  ClienteService(this._api);

  // Devuelve todos los clientes para el preventista.
  Future<List<Cliente>> obtenerClientes({required String token}) async {
    final respuesta = await _api.get('clientes', token: token);

    final dynamic datos = respuesta['data'] ?? respuesta['clientes'];

    if (datos is! List) {
      throw Exception('La API no devolvió una lista válida de clientes.');
    }

    return datos.map((item) {
      final clienteJson = Map<String, dynamic>.from(item);
      return Cliente.fromJson(clienteJson);
    }).toList();
  }

  // Devuelve un solo cliente para simular el usuario cliente.
  Future<Cliente> obtenerMiCliente({required String token}) async {
    final respuesta = await _api.get('cliente', token: token);

    final dynamic datos = respuesta['data'] ?? respuesta['cliente'];
    print(datos);
    return Cliente.fromJson(datos);
  }
}
