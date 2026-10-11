import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/hardware.dart';

class HardwareFormScreen extends StatefulWidget {
  final Hardware? hardware;

  const HardwareFormScreen({super.key, this.hardware});

  @override
  State<HardwareFormScreen> createState() => _HardwareFormScreenState();
}

class _HardwareFormScreenState extends State<HardwareFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _serieController = TextEditingController();

  String _estado = 'Activo';
  @override
  void initState() {
    super.initState();

    final hardware = widget.hardware;

    if (hardware != null) {
      _codigoController.text = hardware.codigo;
      _nombreController.text = hardware.nombre;
      _tipoController.text = hardware.tipo;
      _marcaController.text = hardware.marca;
      _modeloController.text = hardware.modelo;
      _serieController.text = hardware.serie;
      _estado = hardware.estado;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _tipoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _serieController.dispose();

    super.dispose();
  }

  Future<void> _guardarHardware() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hardware = Hardware(
      id: widget.hardware?.id,
      codigo: _codigoController.text.trim(),
      nombre: _nombreController.text.trim(),
      tipo: _tipoController.text.trim(),
      marca: _marcaController.text.trim(),
      modelo: _modeloController.text.trim(),
      serie: _serieController.text.trim(),
      estado: _estado,
      fecha: widget.hardware?.fecha ?? DateTime.now().toIso8601String(),
      sincronizado: 0,
    );

    if (widget.hardware == null) {
      await DatabaseHelper.instance.insertHardware(hardware);
    } else {
      await DatabaseHelper.instance.updateHardware(hardware);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.hardware == null
              ? 'Hardware guardado correctamente'
              : 'Hardware actualizado correctamente',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Hardware')),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del equipo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  hintText: 'Ej. HW-001',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el código';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Computadora de escritorio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.computer),
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
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  hintText: 'Ej. Computadora, impresora, monitor',
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

              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  hintText: 'Ej. Dell',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  hintText: 'Ej. OptiPlex 7090',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.devices),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _serieController,
                decoration: const InputDecoration(
                  labelText: 'Número de serie',
                  hintText: 'Ej. ABC123456',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
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
                  DropdownMenuItem(
                    value: 'Mantenimiento',
                    child: Text('Mantenimiento'),
                  ),
                  DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _estado = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _guardarHardware,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Guardar Hardware',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
