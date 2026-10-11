import 'package:flutter/material.dart';

import '../services/sync_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final SyncService _syncService = SyncService();

  bool _sincronizando = false;
  String _mensaje = 'Pulsa el botón para sincronizar los registros.';
  Map<String, int>? _resultado;

  Future<void> _sincronizar() async {
    setState(() {
      _sincronizando = true;
      _mensaje = 'Sincronizando con Supabase...';
      _resultado = null;
    });

    try {
      final resultado = await _syncService.sincronizarTodo();

      if (!mounted) return;

      setState(() {
        _resultado = resultado;
        _mensaje = 'Sincronización completada correctamente.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensaje = 'No se pudo sincronizar: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _sincronizando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronización')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sync, size: 72, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'SQLite ↔ Supabase',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(_mensaje, textAlign: TextAlign.center),
              if (_resultado != null) ...[
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.computer),
                    title: const Text('Hardware enviado'),
                    trailing: Text('${_resultado!['hardware']}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.apps),
                    title: const Text('Software enviado'),
                    trailing: Text('${_resultado!['software']}'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sincronizando ? null : _sincronizar,
                  icon: _sincronizando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(
                    _sincronizando ? 'Sincronizando...' : 'Sincronizar ahora',
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
