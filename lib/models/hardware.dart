class Hardware {
  final int? id;
  final String codigo;
  final String nombre;
  final String tipo;
  final String marca;
  final String modelo;
  final String serie;
  final String estado;
  final String fecha;
  final int sincronizado;

  Hardware({
    this.id,
    required this.codigo,
    required this.nombre,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.estado,
    required this.fecha,
    this.sincronizado = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'serie': serie,
      'estado': estado,
      'fecha': fecha,
      'sincronizado': sincronizado,
    };
  }

  factory Hardware.fromMap(Map<String, dynamic> map) {
    return Hardware(
      id: map['id'],
      codigo: map['codigo'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      marca: map['marca'],
      modelo: map['modelo'],
      serie: map['serie'],
      estado: map['estado'],
      fecha: map['fecha'],
      sincronizado: map['sincronizado'],
    );
  }
}
