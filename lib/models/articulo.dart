class Articulo {
  final int? id;
  final int inventarioId;
  final int correlativo;
  final String tipo;
  final String habitacion;
  final String descripcion;
  final String estado;
  final String observaciones;
  final int eliminado;
  final int isHighValue; // 0 = normal, 1 = High Value

  Articulo({
    this.id,
    required this.inventarioId,
    required this.correlativo,
    required this.tipo,
    required this.descripcion,
    required this.habitacion,
    required this.estado,
    required this.observaciones,
    required this.eliminado,
    this.isHighValue = 0,
  });

  factory Articulo.fromMap(Map<String, dynamic> map) {
    return Articulo(
      id: map['id'],
      inventarioId: map['inventario_id'],
      correlativo: map['correlativo'],
      descripcion: map['descripcion'],
      tipo: map['tipo'],
      habitacion: map['habitacion'],
      estado: map['estado'],
      observaciones: map['observaciones'],
      eliminado: map['eliminado'],
      isHighValue: map['is_high_value'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inventario_id': inventarioId,
      'correlativo': correlativo,
      'tipo': tipo,
      'descripcion': descripcion,
      'estado': estado,
      'observaciones': observaciones,
      'eliminado': eliminado,
      'is_high_value': isHighValue,
    };
  }
}
