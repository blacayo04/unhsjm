import 'dart:convert';

import 'package:http/http.dart' as http;

import 'dart:async';

class ApiService {
  static Future<http.Response> _ejecutarSolicitud(
    Future<http.Response> solicitud,
  ) async {
    try {
      return await solicitud.timeout(_timeout);
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta nuevamente.');
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión a Internet.',
      );
    } on FormatException {
      throw Exception(
        'La respuesta del servidor no tiene un formato JSON válido.',
      );
    }
  }

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  static const Duration _timeout = Duration(seconds: 15);

  Future<List<Map<String, dynamic>>> obtenerPublicaciones() async {
    final url = Uri.parse('$_baseUrl/posts');
    final response = await _ejecutarSolicitud(http.get(url));

    if (response.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(response.body) as List<dynamic>;

      return datos
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    throw Exception('Error al consultar publicaciones: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> obtenerPublicacion(int id) async {
    final url = Uri.parse('$_baseUrl/posts/$id');
    final response = await _ejecutarSolicitud(http.get(url));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    }

    throw Exception('Error al consultar publicación: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> crearPublicacion({
    required String titulo,
    required String contenido,
  }) async {
    final url = Uri.parse('$_baseUrl/posts');

    final response = await _ejecutarSolicitud(
      http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'title': titulo, 'body': contenido, 'userId': 1}),
      ),
    );

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    }

    throw Exception('Error al crear publicación: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> actualizarPublicacion({
    required int id,
    required String titulo,
    required String contenido,
  }) async {
    final url = Uri.parse('$_baseUrl/posts/$id');

    final response = await _ejecutarSolicitud(
      http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': id,
          'title': titulo,
          'body': contenido,
          'userId': 1,
        }),
      ),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    }

    throw Exception('Error al actualizar publicación: ${response.statusCode}');
  }

  Future<bool> eliminarPublicacion(int id) async {
    final url = Uri.parse('$_baseUrl/posts/$id');
    final response = await _ejecutarSolicitud(http.delete(url));

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception('Error al eliminar publicación: ${response.statusCode}');
  }
}
