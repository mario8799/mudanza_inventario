import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';

class InventarioService {
static Future<int> crearInventarioConArticulos({
  required String numeroInventario,
  required String nombreCliente,
  required String apellidoCliente,
  required List<Map<String, dynamic>> articulos,
}) async {
  final db = await DatabaseHelper.instance.database;

  return await db.transaction((txn) async {
    final inventarioId = await txn.insert('inventarios', {
      'uuid': const Uuid().v4(),
      'numeroInventario': numeroInventario,
      'nombreCliente': nombreCliente,
      'apellidoCliente': apellidoCliente,
      'telefonoCliente': '',
      'direccionOrigen': 'Origen',
      'direccionDestino': 'Destino',
      'fechaCreacion': DateTime.now().toIso8601String(),
      'fechaActualizacion': DateTime.now().toIso8601String(),
      'cerrado': 0,
      'activo': 1,
    });

    final batch = txn.batch();

    for (final articulo in articulos) {
      batch.insert('articulos', {
        'inventario_id': inventarioId,
        'correlativo': articulo['correlativo'],
        'tipo': articulo['tipo'],
        'descripcion': articulo['descripcion'],
        'habitacion': articulo['habitacion'],
        'estado': articulo['estado'],
        'observaciones': articulo['observaciones'],
        'eliminado': 0,
        'is_high_value': articulo['is_high_value'] ?? 0,
      });
    }

    await batch.commit(noResult: true);

    return inventarioId;
  });
}
}