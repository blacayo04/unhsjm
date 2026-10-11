import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _publicaciones = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPublicaciones();
  }

  Future<void> _cargarPublicaciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final publicaciones = await _apiService.obtenerPublicaciones();

      if (!mounted) return;

      setState(() {
        _publicaciones = publicaciones;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _mostrarFormularioCrear() async {
    final tituloController = TextEditingController();
    final contenidoController = TextEditingController();

    try {
      final resultado = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Nueva publicación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contenidoController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.trim().isEmpty ||
                    contenidoController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Completa el título y el contenido.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );

      if (resultado != true || !mounted) return;

      setState(() {
        _cargando = true;
      });

      try {
        await _apiService.crearPublicacion(
          titulo: tituloController.text.trim(),
          contenido: contenidoController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación enviada correctamente.')),
        );

        await _cargarPublicaciones();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear publicación: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _cargando = false;
          });
        }
      }
    } finally {
      tituloController.dispose();
      contenidoController.dispose();
    }
  }

  Future<void> _mostrarFormularioEditar(
    Map<String, dynamic> publicacion,
  ) async {
    final tituloController = TextEditingController(
      text: publicacion['title']?.toString() ?? '',
    );
    final contenidoController = TextEditingController(
      text: publicacion['body']?.toString() ?? '',
    );

    try {
      final resultado = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Editar publicación ${publicacion['id']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contenidoController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.trim().isEmpty ||
                    contenidoController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Completa el título y el contenido.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      );

      if (resultado != true || !mounted) return;

      setState(() => _cargando = true);

      try {
        await _apiService.actualizarPublicacion(
          id: publicacion['id'] as int,
          titulo: tituloController.text.trim(),
          contenido: contenidoController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud de actualización enviada correctamente.'),
          ),
        );

        await _cargarPublicaciones();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar publicación: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _cargando = false);
        }
      }
    } finally {
      tituloController.dispose();
      contenidoController.dispose();
    }
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> publicacion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: Text('¿Deseas eliminar la publicación ${publicacion['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _cargando = true);

    try {
      await _apiService.eliminarPublicacion(publicacion['id'] as int);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de eliminación enviada correctamente.'),
        ),
      );

      await _cargarPublicaciones();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar publicación: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API REST'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: _cargando ? null : _mostrarFormularioCrear,
            icon: const Icon(Icons.add),
            tooltip: 'Crear publicación',
          ),
          IconButton(
            onPressed: _cargando ? null : _cargarPublicaciones,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar publicaciones',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudieron cargar los datos.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _cargarPublicaciones,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : _publicaciones.isEmpty
          ? const Center(child: Text('No hay publicaciones disponibles.'))
          : RefreshIndicator(
              onRefresh: _cargarPublicaciones,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _publicaciones.length,
                itemBuilder: (context, index) {
                  final publicacion = _publicaciones[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${publicacion['id']}'),
                      ),
                      title: Text(
                        publicacion['title']?.toString() ?? 'Sin título',
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          publicacion['body']?.toString() ?? 'Sin contenido',
                        ),
                      ),

                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Editar publicación',
                            onPressed: _cargando
                                ? null
                                : () => _mostrarFormularioEditar(publicacion),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar publicación',
                            onPressed: _cargando
                                ? null
                                : () => _confirmarEliminar(publicacion),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
