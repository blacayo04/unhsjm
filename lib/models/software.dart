class Software {
  final int? id;
  final String nombre;
  final String version;
  final String fabricante;
  final String tipo;
  final String estado;
  final String fecha;
  final int sincronizado;

  Software({
    this.id,
    required this.nombre,
    required this.version,
    required this.fabricante,
    required this.tipo,
    required this.estado,
    required this.fecha,
    this.sincronizado = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'version': version,
      'fabricante': fabricante,
      'tipo': tipo,
      'estado': estado,
      'fecha': fecha,
      'sincronizado': sincronizado,
    };
  }

  factory Software.fromMap(Map<String, dynamic> map) {
    return Software(
      id: map['id'],
      nombre: map['nombre'],
      version: map['version'],
      fabricante: map['fabricante'],
      tipo: map['tipo'],
      estado: map['estado'],
      fecha: map['fecha'],
      sincronizado: map['sincronizado'],
    );
  }
}
