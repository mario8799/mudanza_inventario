import '../database/database_helper.dart';
import '../services/pdf_service.dart';

Future<void> generarPdfCompleto(int inventarioId) async {
  final db = await DatabaseHelper.instance.database;
  final inventario = (await db.query('inventarios', where: 'id = ?', whereArgs: [inventarioId])).first;
  final articulos = await db.query('articulos', where: 'inventario_id = ? AND eliminado = 0', whereArgs: [inventarioId], orderBy: 'correlativo ASC');

  await PdfService.generarPdf(inventario: inventario, articulos: articulos, tipo: "NORMAL");
}

Future<void> generarPdfHighValue(int inventarioId) async {
  final db = await DatabaseHelper.instance.database;
  final inventario = (await db.query('inventarios', where: 'id = ?', whereArgs: [inventarioId])).first;
  final articulos = await db.query('articulos', where: 'inventario_id = ? AND is_high_value = 1 AND eliminado = 0', whereArgs: [inventarioId], orderBy: 'correlativo ASC');

  await PdfService.generarPdf(inventario: inventario, articulos: articulos, tipo: "HV");
}

Future<void> generarPdfProGear(int inventarioId) async {
  final db = await DatabaseHelper.instance.database;
  final inventario = (await db.query('inventarios', where: 'id = ?', whereArgs: [inventarioId])).first;
  final articulos = await db.query('articulos', where: 'inventario_id = ? AND eliminado = 0', whereArgs: [inventarioId], orderBy: 'correlativo ASC');

  await PdfService.generarPdf(inventario: inventario, articulos: articulos, tipo: "PROGEAR");
}