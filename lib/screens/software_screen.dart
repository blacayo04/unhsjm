import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/software.dart';
import 'software_form_screen.dart';

class SoftwareScreen extends StatefulWidget {
  const SoftwareScreen({super.key});

  @override
  State<SoftwareScreen> createState() => _SoftwareScreenState();
}

class _SoftwareScreenState extends State<SoftwareScreen> {
  Future<void> _abrirFormulario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SoftwareFormScreen()),
    );

    await _cargarSoftware();
  }

  Future<void> _editarSoftware(Software software) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SoftwareFormScreen(software: software),
      ),
    );

    await _cargarSoftware();
  }

  Future<void> _eliminarSoftware(Software software) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar software'),
        content: Text('¿Deseas eliminar "${software.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await DatabaseHelper.instance.deleteSoftware(software.id!);

    if (!mounted) return;

    await _cargarSoftware();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Software eliminado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Software')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _software.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apps, size: 70),
                  SizedBox(height: 15),
                  Text(
                    'No hay software registrado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Presiona + para agregar un software'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _software.length,
              itemBuilder: (context, index) {
                final item = _software[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.apps)),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${item.fabricante} • ${item.version}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(label: Text(item.estado)),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Editar software',
                          onPressed: () => _editarSoftware(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar software',
                          onPressed: () => _eliminarSoftware(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Software> _software = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarSoftware();
  }

  Future<void> _cargarSoftware() async {
    final software = await DatabaseHelper.instance.getSoftware();

    if (!mounted) return;

    setState(() {
      _software = software;
      _cargando = false;
    });
  }
}
