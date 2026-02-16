import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'add_item_screen.dart';
import 'firma_operador_screen.dart';
import '../models/articulo.dart';
import '../services/printer_service.dart';
// Importamos el nuevo generador con un alias para mayor claridad
import '../services/pdf_generator_service.dart' as Generator;

class InventarioScreen extends StatefulWidget {
  final int inventarioId;
  final String numeroInventario;

  const InventarioScreen({
    super.key,
    required this.inventarioId,
    required this.numeroInventario,
  });

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List<Articulo> articulos = [];
  bool existeHighValue = false;
  bool inventarioCerrado = false;
  Map<String, dynamic>? inventarioData;

  @override
  void initState() {
    super.initState();
    cargarArticulos();
    cargarInventario();
    cargarEstadoInventario();
  }

  Future<void> cargarEstadoInventario() async {
    final inv = await DatabaseHelper.instance.getInventarioById(widget.inventarioId);
    setState(() {
      inventarioCerrado = inv['cerrado'] == 1;
    });
  }

  // --- LÓGICA DE DATOS ---

  Future<void> cargarInventario() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'inventarios',
      where: 'id = ?',
      whereArgs: [widget.inventarioId],
    );

    if (result.isNotEmpty) {
      setState(() {
        inventarioData = result.first;
      });
    }
  }

  Future<void> cargarArticulos() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query(
      'articulos',
      where: 'inventario_id = ?',
      whereArgs: [widget.inventarioId],
      orderBy: 'correlativo ASC',
    );
    final listaArticulos = data.map((map) => Articulo.fromMap(map)).toList();

    final hayHV = listaArticulos.any((a) => a.isHighValue == 1);

    setState(() {
      articulos = listaArticulos;
      existeHighValue = hayHV;
    });
  }

  // --- NUEVA LÓGICA DE PDFS USANDO EL SERVICIO PÚBLICO ---

  Future<void> generarPdfHighValue() async {
    await Generator.generarPdfHighValue(widget.inventarioId);
  }

  Future<void> mostrarOpcionesPdf() async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Bordes redondeados
  title: const Text("Tipo de Inventario"),
  content: const Text("¿Este reporte corresponde a Equipo Profesional (ProGear)?"),
  actions: [
    TextButton(
      onPressed: () {
        Navigator.pop(context);
        Generator.generarPdfCompleto(widget.inventarioId);
      },
      child: const Text("NO, NORMAL", style: TextStyle(color: Colors.grey)),
    ),
    ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Generator.generarPdfProGear(widget.inventarioId);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade700, // Un naranja profesional
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("SÍ, ES PROGEAR"),
    ),
  ],
);
    },
  );
}

  // --- UTILIDADES ---

  Future<int> obtenerSiguienteCorrelativo() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT MAX(correlativo) as max FROM articulos WHERE inventario_id = ?',
      [widget.inventarioId],
    );
    final max = result.first['max'] as int?;
    return (max ?? 0) + 1;
  }

  String formatearCorrelativo(int correlativo) {
    return correlativo.toString().padLeft(4, '0');
  }

  // --- ACCIONES ---

  Future<void> agregarArticulo() async {
    int nuevoCorrelativo = await obtenerSiguienteCorrelativo();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          correlativo: nuevoCorrelativo,
          onSave: (itemData) async {
            final db = await DatabaseHelper.instance.database;
            await db.insert('articulos', {
              'inventario_id': widget.inventarioId,
              'correlativo': nuevoCorrelativo,
              'tipo': itemData['tipo'],
              'descripcion': itemData['description'],
              'habitacion': itemData['room'],
              'estado': itemData['condition'],
              'observaciones': itemData['notes'],
              'eliminado': 0,
              'is_high_value': itemData['isHighValue'] ?? 0,
            });
          },
        ),
      ),
    );
    await cargarArticulos();
  }

  Future<void> editarArticulo(Articulo articulo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          correlativo: articulo.correlativo,
          articuloExistente: articulo,
          onSave: (itemData) async {
            final db = await DatabaseHelper.instance.database;
            await db.update(
              'articulos',
              {
                'tipo': itemData['tipo'] ?? itemData['name'],
                'descripcion': itemData['description'],
                'habitacion': itemData['room'],
                'estado': itemData['condition'],
                'observaciones': itemData['notes'],
                'is_high_value': itemData['isHighValue'] ?? 0,
              },
              where: 'id = ?',
              whereArgs: [articulo.id],
            );
          },
        ),
      ),
    );
    await cargarArticulos();
  }

  Future<void> confirmarEliminacion(int id) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Desea marcar este artículo como eliminado?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await marcarComoEliminado(id);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> marcarComoEliminado(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'articulos',
      {'eliminado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    await cargarArticulos();
  }

  void mostrarConfirmacionCierre() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar cierre"),
        content: const Text(
          "¿Está seguro que desea cerrar este inventario?\n\nLuego no podrá modificar los artículos.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.cerrarInventario(widget.inventarioId);
              if (mounted) {
                setState(() {
                  inventarioCerrado = true;
                });
              }
              irAFirmaOperador();
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  Future<void> irAFirmaOperador() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirmaOperadorScreen(
          inventarioId: widget.inventarioId,
        ),
      ),
    );

    if (resultado == true) {
      await cargarInventario();
      setState(() {});
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool mostrarPdf = inventarioData != null &&
        inventarioData!['activo'] == 0 &&
        inventarioData!['firmaOperador'] != null &&
        inventarioData!['firmaCliente'] != null;

    return Scaffold(
      appBar: AppBar(
        title: Text("Inventario ${widget.numeroInventario}"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: inventarioCerrado ? null : agregarArticulo,
            icon: const Icon(Icons.add),
            label: const Text("Agregar artículo"),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: articulos.length,
              itemBuilder: (context, index) {
                final articulo = articulos[index];
                bool eliminado = articulo.eliminado == 1;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(
                      "${widget.numeroInventario}-${formatearCorrelativo(articulo.correlativo)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: eliminado ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      eliminado ? "ELIMINADO" : articulo.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: eliminado ? Colors.red : Colors.grey[600],
                      ),
                    ),
                    trailing: articulo.isHighValue == 1
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "HV",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow("Tipo", articulo.tipo),
                            _buildDetailRow("Descripción", articulo.descripcion),
                            _buildDetailRow("Habitación", articulo.habitacion),
                            _buildDetailRow("Estado", articulo.estado),
                            _buildDetailRow("Observaciones", articulo.observaciones),
                            const Divider(),
                            // --- Dentro del Row de botones de cada artículo ---
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // El botón de IMPRIMIR siempre debe ser visible
    TextButton.icon(
      onPressed: () async {
        await PrinterService.printArticulo(articulo);
      },
      icon: const Icon(Icons.print, size: 18),
      label: const Text("Imprimir"),
    ),

    // Solo si el inventario NO está cerrado, renderizamos Editar y Eliminar
    if (!inventarioCerrado) ...[
      const SizedBox(width: 10),
      TextButton.icon(
        onPressed: () => editarArticulo(articulo),
        icon: const Icon(Icons.edit, size: 18),
        label: const Text("Editar"),
      ),
      const SizedBox(width: 10),
      TextButton.icon(
        onPressed: () => confirmarEliminacion(articulo.id!),
        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
        label: const Text(
          "Eliminar",
          style: TextStyle(color: Colors.red),
        ),
      ),
    ],
  ],
),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // --- BOTONES INFERIORES ---
          if (mostrarPdf && existeHighValue)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: generarPdfHighValue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "GENERAR HIGH VALUE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          if (mostrarPdf)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Cambiamos la llamada directa por el diálogo
        onPressed: mostrarOpcionesPdf, 
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, 
          foregroundColor: Colors.white
        ),
        child: const Text(
          "GENERAR PDF", 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        ),
      ),
    ),
  ),
          if (inventarioData == null || inventarioData!['activo'] == 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: mostrarConfirmacionCierre,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text("CERRAR INVENTARIO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}