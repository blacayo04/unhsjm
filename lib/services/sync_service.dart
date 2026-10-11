import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';
import '../models/hardware.dart';
import '../models/software.dart';

class SyncService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Map<String, int>> sincronizarTodo() async {
    if (_supabase.auth.currentSession == null) {
      throw Exception('Debes iniciar sesión para sincronizar.');
    }

    int hardwareEnviados = 0;
    int softwareEnviados = 0;

    // Enviar hardware pendiente. El servidor genera su propio ID.
    final hardwarePendiente = await _db.getPendingSyncHardware();

    for (final Hardware item in hardwarePendiente) {
      final registro = <String, dynamic>{
        'codigo': item.codigo,
        'nombre': item.nombre,
        'tipo': item.tipo,
        'marca': item.marca,
        'modelo': item.modelo,
        'serie': item.serie,
        'estado': item.estado,
        'fecha': item.fecha,
        'sincronizado': 1,
      };

      await _supabase.from('hardware').upsert(registro, onConflict: 'codigo');

      if (item.id != null) {
        await _db.marcarHardwareSincronizado(item.id!);
      }

      hardwareEnviados++;
    }

    // Enviar software pendiente.
    final softwarePendiente = await _db.getPendingSyncSoftware();

    for (final Software item in softwarePendiente) {
      final registro = <String, dynamic>{
        'nombre': item.nombre,
        'version': item.version,
        'fabricante': item.fabricante,
        'tipo': item.tipo,
        'estado': item.estado,
        'fecha': item.fecha,
        'sincronizado': 1,
      };

      await _supabase.from('software').insert(registro);

      if (item.id != null) {
        await _db.marcarSoftwareSincronizado(item.id!);
      }

      softwareEnviados++;
    }

    final hardwareRemoto = await _supabase.from('hardware').select();

    for (final registro in hardwareRemoto) {
      await _db.guardarHardwareDescargado(Map<String, dynamic>.from(registro));
    }

    final softwareRemoto = await _supabase.from('software').select();

    for (final registro in softwareRemoto) {
      await _db.guardarSoftwareDescargado(Map<String, dynamic>.from(registro));
    }

    return {'hardware': hardwareEnviados, 'software': softwareEnviados};
  }
}
