import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/software.dart';

class SoftwareFormScreen extends StatefulWidget {
  const SoftwareFormScreen({super.key, this.software});

  final Software? software;

  @override
  State<SoftwareFormScreen> createState() => _SoftwareFormScreenState();
}

class _SoftwareFormScreenState extends State<SoftwareFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _versionController = TextEditingController();
  final _fabricanteController = TextEditingController();
  final _tipoController = TextEditingController();

  String _estado = 'Activo';

  @override
  void initState() {
    super.initState();

    final software = widget.software;

    if (software != null) {
      _nombreController.text = software.nombre;
      _versionController.text = software.version;
      _fabricanteController.text = software.fabricante;
      _tipoController.text = software.tipo;
      _estado = software.estado;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _versionController.dispose();
    _fabricanteController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  Future<void> _guardarSoftware() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final softwareActualizado = Software(
      id: widget.software?.id,
      nombre: _nombreController.text.trim(),
      version: _versionController.text.trim(),
      fabricante: _fabricanteController.text.trim(),
      tipo: _tipoController.text.trim(),
      estado: _estado,
      fecha: widget.software?.fecha ?? DateTime.now().toIso8601String(),
      sincronizado: 0,
    );

    if (widget.software == null) {
      await DatabaseHelper.instance.insertSoftware(softwareActualizado);
    } else {
      await DatabaseHelper.instance.updateSoftware(softwareActualizado);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.software == null
              ? 'Software guardado correctamente'
              : 'Software actualizado correctamente',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.software == null ? 'Registrar Software' : 'Editar Software',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del software',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apps),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _versionController,
                decoration: const InputDecoration(
                  labelText: 'Versión',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fabricanteController,
                decoration: const InputDecoration(
                  labelText: 'Fabricante',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  hintText: 'Ej. Sistema operativo, ofimática, antivirus',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el tipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                  DropdownMenuItem(
                    value: 'Desinstalado',
                    child: Text('Desinstalado'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _estado = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _guardarSoftware,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Software'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
