import '../database/database_helper.dart';
import '../services/pdf_service.dart';

/// Genera PDF completo del inventario
Future<void> generarPdfCompleto(int inventarioId) async {
  final db = await DatabaseHelper.instance.database;

  // Traemos inventario
  final inventario = (await db.query(
    'inventarios',
    where: 'id = ?',
    whereArgs: [inventarioId],
  )).first;

  // Traemos todos los artículos activos
  final articulos = await db.query(
    'articulos',
    where: 'inventario_id = ? AND eliminado = 0',
    whereArgs: [inventarioId],
    orderBy: 'correlativo ASC',
  );

  // Generamos PDF usando el servicio
  await PdfService.generarPdf(
    inventario: inventario,
    articulos: articulos,
  );
}

/// Genera PDF solo con artículos de alto valor
Future<void> generarPdfHighValue(int inventarioId) async {
  final db = await DatabaseHelper.instance.database;

  // Traemos inventario
  final inventario = (await db.query(
    'inventarios',
    where: 'id = ?',
    whereArgs: [inventarioId],
  )).first;

  // Traemos solo artículos de alto valor
  final articulos = await db.query(
    'articulos',
    where: 'inventario_id = ? AND is_high_value = 1 AND eliminado = 0',
    whereArgs: [inventarioId],
    orderBy: 'correlativo ASC',
  );

  // Generamos PDF usando el mismo método
  await PdfService.generarPdf(
    inventario: inventario,
    articulos: articulos,
  );
}
