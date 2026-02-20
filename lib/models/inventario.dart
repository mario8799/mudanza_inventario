class Inventario {
  final int? id;

  final String uuid; // Identificador global
  final String numeroInventario;

  final String nombreCliente;
  final String apellidoCliente;
  final String telefonoCliente;

  final String direccionOrigen;
  final String direccionDestino;

  final String fechaCreacion;
  final String fechaActualizacion;
  final String? fechaCierre;

  final String nombreOperador;
  final String? firmaOperador;
  final String? firmaCliente;

  final int estadoSync; // 0 = no sync, 1 = sync, 2 = modificado
  final int eliminado; // 0 = activo, 1 = marcado eliminar
  final String? fechaEliminacion;

  final int activo;


  Inventario({
    this.id,
    required this.uuid,
    required this.numeroInventario,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.telefonoCliente,
    required this.direccionOrigen,
    required this.direccionDestino,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.fechaCierre,
    this.firmaOperador,
    this.firmaCliente,
    this.estadoSync = 0,
    this.eliminado = 0,
    this.fechaEliminacion,
    required this.activo,
    required this.nombreOperador,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'numeroInventario': numeroInventario,
      'nombreOperador': nombreOperador,
      'nombreCliente': nombreCliente,
      'apellidoCliente': apellidoCliente,
      'telefonoCliente': telefonoCliente,
      'direccionOrigen': direccionOrigen,
      'direccionDestino': direccionDestino,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': fechaActualizacion,
      'fechaCierre': fechaCierre,
      'firmaOperador': firmaOperador,
      'firmaCliente': firmaCliente,
      'estado_sync': estadoSync,
      'eliminado': eliminado,
      'fecha_eliminacion': fechaEliminacion,
      'activo': activo,
    };
  }
}
