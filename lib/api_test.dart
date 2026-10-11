import 'services/api_service.dart';

// ignore_for_file: avoid_print

Future<void> main() async {
  final api = ApiService();

  try {
    print('Enviando solicitud DELETE...');

    final eliminado = await api.eliminarPublicacion(1);

    if (eliminado) {
      print('Solicitud de eliminación exitosa.');
      print('ID solicitado para eliminar: 1');
      print('Código HTTP esperado: 200');
    }
  } catch (e) {
    print('Error al eliminar la publicación: $e');
  }
}
