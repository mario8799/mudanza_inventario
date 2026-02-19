import '../database/database_helper.dart';
import '../services/pdf_service.dart';
import 'dart:typed_data';

String generarNombreArchivo({
  required Map<String, dynamic> inventario,
  required String tipo, // "NORMAL", "HV", "PROGEAR"
}) {
  // 🔹 Número siempre con 4 dígitos
  final numero = inventario['numeroInventario']
      .toString()
      .padLeft(5, '0');

  final nombre = inventario['nombreCliente']
      .toString()
      .replaceAll(' ', '');

  final apellido = inventario['apellidoCliente']
      .toString()
      .replaceAll(' ', '');

  final fechaCreacion =
      DateTime.parse(inventario['fechaCreacion']);

  final fechaFormateada =
      "${fechaCreacion.year}-"
      "${fechaCreacion.month.toString().padLeft(2, '0')}-"
      "${fechaCreacion.day.toString().padLeft(2, '0')}";

  // 🔹 Etiqueta según tipo
  String etiqueta = "";

  if (tipo == "HV") {
    etiqueta = "_HV";
  } else if (tipo == "PROGEAR") {
    etiqueta = "_PG";
  }

  return "$numero"
      "_$nombre"
      "_$apellido"
      "_$fechaFormateada"
      "$etiqueta"
      ".pdf";
}

Future<void> generarPdfCompleto(int inventarioId) async {


  final db = await DatabaseHelper.instance.database;

  final inventario = (await db.query(
    'inventarios',
    where: 'id = ?',
    whereArgs: [inventarioId],
  )).first;

  final fechaInventario = inventario['fechaCreacion'] != null
    ? DateTime.tryParse(inventario['fechaCreacion'].toString()) ?? DateTime.now()
    : DateTime.now();

  final articulos = await db.query(
    'articulos',
    where: 'inventario_id = ? AND eliminado = 0',
    whereArgs: [inventarioId],
    orderBy: 'correlativo ASC',
  );

  final nombreArchivo =
      generarNombreArchivo(
        inventario: inventario,
        tipo: "NORMAL",
      );

  await PdfService.generarPdf(
  inventario: inventario,
  articulos: articulos,
  tipo: "NORMAL",
  nombreArchivo: nombreArchivo,
  fechaInventario: fechaInventario,
 firmaOperador: inventario['firmaOperador'] as Uint8List?,
firmaCliente: inventario['firmaCliente'] as Uint8List?,
);

}

Future<void> generarPdfHighValue(int inventarioId) async {

  final db = await DatabaseHelper.instance.database;

  final inventario = (await db.query(
    'inventarios',
    where: 'id = ?',

    whereArgs: [inventarioId],
  )).first;

  final fechaInventario = inventario['fechaCreacion'] != null
    ? DateTime.tryParse(inventario['fechaCreacion'].toString()) ?? DateTime.now()
    : DateTime.now();

  final articulos = await db.query(
    'articulos',
    where:
        'inventario_id = ? AND is_high_value = 1 AND eliminado = 0',
    whereArgs: [inventarioId],
    orderBy: 'correlativo ASC',
  );

  final nombreArchivo =
      generarNombreArchivo(
        inventario: inventario,
        tipo: "HV",
      );

  await PdfService.generarPdf(
  inventario: inventario,
  articulos: articulos,
  tipo: "HV", // o "PROGEAR"
  nombreArchivo: nombreArchivo,
  fechaInventario: fechaInventario,
  firmaOperador: inventario['firmaOperador'] as Uint8List?,
  firmaCliente: inventario['firmaCliente'] as Uint8List?,
);

}

Future<void> generarPdfProGear(int inventarioId) async {

  final db = await DatabaseHelper.instance.database;

  final inventario = (await db.query(
    'inventarios',
    where: 'id = ?',
    whereArgs: [inventarioId],
  )).first;

final fechaInventario = inventario['fechaCreacion'] != null
    ? DateTime.tryParse(inventario['fechaCreacion'].toString()) ?? DateTime.now()
    : DateTime.now();

  final articulos = await db.query(
    'articulos',
    where: 'inventario_id = ? AND eliminado = 0',
    whereArgs: [inventarioId],
    orderBy: 'correlativo ASC',
  );

  final nombreArchivo =
      generarNombreArchivo(
        inventario: inventario,
        tipo: "PROGEAR",
      );

 await PdfService.generarPdf(
  inventario: inventario,
  articulos: articulos,
  tipo: "HV", // o "PROGEAR"
  nombreArchivo: nombreArchivo,
  fechaInventario: fechaInventario,
  firmaOperador: inventario['firmaOperador'] as Uint8List?,
  firmaCliente: inventario['firmaCliente'] as Uint8List?,
);
}