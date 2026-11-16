import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Emulador Android: accede al servidor Laravel de la computadora.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // GET: consultar información.
  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final response = await _client
        .get(_crearUri(endpoint), headers: _headers(token))
        .timeout(const Duration(seconds: 20));

    return _procesarRespuesta(response);
  }

  // POST: crear registros o enviar datos.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _client
        .post(
          _crearUri(endpoint),
          headers: _headers(token),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 20));

    return _procesarRespuesta(response);
  }

  // PUT: actualizar registros.
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _client
        .put(
          _crearUri(endpoint),
          headers: _headers(token),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 20));

    return _procesarRespuesta(response);
  }

  // DELETE: eliminar registros.
  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    final response = await _client
        .delete(_crearUri(endpoint), headers: _headers(token))
        .timeout(const Duration(seconds: 20));

    return _procesarRespuesta(response);
  }

  // Construye la URL del endpoint.
  Uri _crearUri(String endpoint) {
    final ruta = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

    return Uri.parse('$baseUrl/$ruta');
  }

  // Cabeceras comunes para las solicitudes.
  Map<String, String> _headers(String? token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Procesa respuestas exitosas y errores de Laravel.
  Map<String, dynamic> _procesarRespuesta(http.Response response) {
    final String cuerpo = response.body;

    Map<String, dynamic> datos = {};

    if (cuerpo.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(cuerpo);

        if (decoded is Map<String, dynamic>) {
          datos = decoded;
        } else if (decoded is List) {
          datos = {'data': decoded}; // listas se devuelven bajo la clave 'data'
        } else {
          throw const FormatException(
            'El servidor devolvió un formato inesperado.',
          );
        }
      } on FormatException {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          rethrow;
        }

        throw Exception(
          'El servidor devolvió una respuesta no válida '
          '(HTTP ${response.statusCode}).',
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return datos;
    }

    final errores = datos['errors'];

    if (errores is Map) {
      final mensajes = errores.values
          .whereType<List>()
          .expand((lista) => lista)
          .map((error) => error.toString())
          .toList();

      if (mensajes.isNotEmpty) {
        throw Exception(mensajes.join('\n'));
      }
    }

    throw Exception(
      datos['message']?.toString() ?? 'Error HTTP ${response.statusCode}.',
    );
  }

  // Cierra el cliente HTTP cuando ya no se necesita.
  void dispose() {
    _client.close();
  }
}
