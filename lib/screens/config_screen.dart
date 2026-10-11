import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cerrar sesión: ${e.message}')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.blue),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Cuenta de usuario',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Correo electrónico'),
              subtitle: Text(usuario?.email ?? 'No hay una sesión activa'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Base de datos'),
              subtitle: const Text('Supabase PostgreSQL'),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: usuario == null ? null : () => _cerrarSesion(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
