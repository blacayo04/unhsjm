import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/hardware.dart';
import 'hardware_form_screen.dart';

class HardwareScreen extends StatefulWidget {
  const HardwareScreen({super.key});

  @override
  State<HardwareScreen> createState() => _HardwareScreenState();
}

class _HardwareScreenState extends State<HardwareScreen> {
  List<Hardware> _hardware = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHardware();
  }

  Future<void> _cargarHardware() async {
    final hardware = await DatabaseHelper.instance.getHardware();

    if (!mounted) return;

    setState(() {
      _hardware = hardware;
      _cargando = false;
    });
  }

  Future<void> _abrirFormulario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HardwareFormScreen()),
    );

    _cargarHardware();
  }

  Future<void> _eliminarHardware(int id) async {
    await DatabaseHelper.instance.deleteHardware(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hardware eliminado correctamente')),
    );

    _cargarHardware();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hardware')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _hardware.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 70),
                  SizedBox(height: 15),
                  Text(
                    'No hay hardware registrado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Presiona + para agregar un equipo'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _hardware.length,
              itemBuilder: (context, index) {
                final item = _hardware[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.computer)),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item.codigo} • ${item.marca} ${item.modelo}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar',
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HardwareFormScreen(hardware: item),
                              ),
                            );

                            _cargarHardware();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Eliminar',
                          onPressed: () async {
                            if (item.id == null) return;

                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Eliminar hardware'),
                                  content: Text(
                                    '¿Desea eliminar "${item.nombre}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmar == true) {
                              await _eliminarHardware(item.id!);
                            }
                          },
                        ),
                        Chip(label: Text(item.estado)),
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
}
