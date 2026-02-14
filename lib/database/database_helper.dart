import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // ================= GET DATABASE =================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventario.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  // ================= CREATE TABLES =================

  Future _createDB(Database db, int version) async {

    await db.execute('''
    CREATE TABLE inventarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      uuid TEXT NOT NULL,
      numeroInventario TEXT,
      nombreCliente TEXT,
      apellidoCliente TEXT,
      telefonoCliente TEXT,
      direccionOrigen TEXT,
      direccionDestino TEXT,
      fechaCreacion TEXT,
      fechaActualizacion TEXT,
      fechaCierre TEXT,
      firmaOperador TEXT,
      firmaCliente TEXT,
      estado_sync INTEGER DEFAULT 0,
      eliminado INTEGER DEFAULT 0,
      fecha_eliminacion TEXT,
      cerrado INTEGER NOT NULL DEFAULT 0,
      activo INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE articulos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tipo TEXT,
      habitacion TEXT,
      inventario_id INTEGER,
      correlativo INTEGER,
      descripcion TEXT,
      estado TEXT,
      observaciones TEXT,
      eliminado INTEGER DEFAULT 0,
      is_high_value INTEGER NOT NULL DEFAULT 0
    )
    ''');
  }

  // ================= INVENTARIOS =================

  Future<Map<String, dynamic>> getInventarioById(int id) async {
    final db = await database;

    final result = await db.query(
      'inventarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.first;
  }

  Future<void> cerrarInventario(int id) async {
    final db = await database;

    await db.update(
      'inventarios',
      {
        'cerrado': 1,
        'fechaCierre': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarInventarioEliminado(int id) async {
    final db = await database;

    await db.update(
      'inventarios',
      {
        'eliminado': 1,
        'fecha_eliminacion': DateTime.now().toIso8601String(),
        'fechaActualizacion': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getInventariosActivos() async {
    final db = await database;

    return await db.query(
      'inventarios',
      where: 'eliminado = ?',
      whereArgs: [0],
      orderBy: 'fechaCreacion DESC',
    );
  }

  // ================= ARTICULOS (BLINDADOS) =================

  Future<void> insertArticulo(Map<String, dynamic> data) async {
    final db = await database;

    await db.rawInsert('''
      INSERT INTO articulos (
        tipo,
        habitacion,
        inventario_id,
        correlativo,
        descripcion,
        estado,
        observaciones,
        eliminado,
        is_high_value
      )
      SELECT ?,?,?,?,?,?,?,?,?
      WHERE EXISTS (
        SELECT 1 FROM inventarios
        WHERE id = ? AND cerrado = 0
      )
    ''', [
      data['tipo'],
      data['habitacion'],
      data['inventario_id'],
      data['correlativo'],
      data['descripcion'],
      data['estado'],
      data['observaciones'],
      data['eliminado'] ?? 0,
      data['is_high_value'] ?? 0,
      data['inventario_id'],
    ]);
  }

  Future<void> updateArticulo(int id, Map<String, dynamic> data) async {
    final db = await database;

    await db.update(
      'articulos',
      data,
      where: '''
        id = ?
        AND inventario_id IN (
          SELECT id FROM inventarios WHERE cerrado = 0
        )
      ''',
      whereArgs: [id],
    );
  }

  Future<void> deleteArticulo(int id) async {
    final db = await database;

    await db.delete(
      'articulos',
      where: '''
        id = ?
        AND inventario_id IN (
          SELECT id FROM inventarios WHERE cerrado = 0
        )
      ''',
      whereArgs: [id],
    );
  }
}