import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class PdfService {

  static Future<void> generarPdf({
    required Map<String, dynamic> inventario,
    required List<Map<String, dynamic>> articulos,
    required String tipo, // "NORMAL", "HV", "PROGEAR"
    required String nombreArchivo,
    Uint8List? firmaOperador,
    Uint8List? firmaCliente,
    required DateTime fechaInventario,
  }) async {

    final codigoInventario = inventario['numeroInventario']?.toString() ?? '';
    final String nombreOperador = inventario['nombreOperador']?.toString() ?? "";
    final String nombre = inventario['nombreCliente'] ?? '';
    final String apellido = inventario['apellidoCliente'] ?? '';
    final String shipperName = "$nombre $apellido".trim();

    final pdf = pw.Document();

    // 🔹 Elegir plantilla
    final templateBytes = await rootBundle.load(
      tipo == "PROGEAR"
          ? "assets/pdfs/progear_inventory.png"
          : "assets/pdfs/normal_inventory.png",
    );

    final template = pw.MemoryImage(templateBytes.buffer.asUint8List());

    final totalArticulos = articulos.length;

    const double margenCm = 1.6;
    const double headerTopCm = 3;
    const double primeraFilaTopCm = 9.7;
    const double altoFilaCm = 0.4;

    const double anchoItem = 1.2;
    const double anchoType = 1.4;
    const double anchoArticle = 11.2;

    // 🔹 Dividir en páginas de 30 filas
    List<List<Map<String, dynamic>>> paginas = [];

    for (int i = 0; i < articulos.length; i += 30) {
      paginas.add(
        articulos.sublist(
          i,
          i + 30 > articulos.length ? articulos.length : i + 30,
        ),
      );
    }

    if (paginas.isEmpty) {
      paginas.add([]);
    }

    for (int pagina = 0; pagina < paginas.length; pagina++) {
      final articulosPagina = paginas[pagina];
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Stack(
              children: [

                // Fondo del formulario
                pw.Positioned.fill(
                  child: pw.Image(
                    template,
                    fit: pw.BoxFit.fill,
                  ),
                ),

                // 🔹 HEADER

// Agent
_posCm(
  top: 3.5,
  left: 12,
  child: pw.Text(
    nombreOperador,
    style: const pw.TextStyle(fontSize: 9),
  ),
),

// Shipper’s Name
_posCm(
  top: 4.1,
  left: 4,
  child: pw.Text(
    "$shipperName",
    style: const pw.TextStyle(fontSize: 9),
  ),
),


                _posCm(
                  top: headerTopCm - 0.8,
                  left: 8.5,
                  child: pw.Text(
                    " $codigoInventario",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),

                _posCm(
                  top: headerTopCm,
                  left: margenCm,
                  child: pw.Text(
                    "Cornerstone Moving & Storage",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),

                _posCm(
                  top: headerTopCm + 2.1,
                  left: 4,
                  child: pw.Text(
                    inventario['direccionOrigen'] ?? "",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),

                _posCm(
                  top: headerTopCm + 3.1,
                  left: 4,
                  child: pw.Text(
                    inventario['direccionDestino'] ?? "",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),

                // 🔹 FILAS
                for (int i = 0; i < articulosPagina.length; i++)
                  ..._buildFila(
                    articulosPagina[i],
                    primeraFilaTopCm + (i * altoFilaCm),
                    margenCm,
                    anchoItem,
                    anchoType,
                    anchoArticle,
                  ),

                // 🔹 TOTAL
                if (pagina == paginas.length - 1)
                  _posCm(
                    top: 22.23,
                    left: 9.5,
                    child: pw.Text(
                      totalArticulos.toString(),
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),

                // 🔹 FIRMAS y FECHAS
                if (firmaOperador != null && firmaOperador.isNotEmpty)
  _posCm(
    top: 23.5,
    left: 3,
    child: pw.Image(
      pw.MemoryImage(firmaOperador),
      width: 2 * PdfPageFormat.cm,
      height: 1 * PdfPageFormat.cm,
    ),
  ),


                if (firmaCliente != null)
                  _posCm(
                    top: 25,
                    left: 3,
                    child: pw.Image(
                      pw.MemoryImage(firmaCliente),
                      width: 2 * PdfPageFormat.cm,
                      height: 1 * PdfPageFormat.cm,
                    ),
                  ),

                // Fecha Operador
                _posCm(
                  top: 23.8,
                  left: 8.6,
                  child: pw.Text(
                    DateFormat('dd/MM/yyyy').format(fechaInventario),
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),

                // Fecha Cliente
                _posCm(
                  top: 25.3,
                  left: 8.6,
                  child: pw.Text(
                    DateFormat('dd/MM/yyyy').format(fechaInventario),
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final pdfBytes = await pdf.save();

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: nombreArchivo,
    );
  }

  static pw.Widget _posCm({
    required double top,
    required double left,
    required pw.Widget child,
  }) {
    return pw.Positioned(
      top: top * PdfPageFormat.cm,
      left: left * PdfPageFormat.cm,
      child: child,
    );
  }

  static List<pw.Widget> _buildFila(
    Map<String, dynamic> articulo,
    double topCm,
    double margenCm,
    double anchoItem,
    double anchoType,
    double anchoArticle,
  ) {
    return [
      _posCm(
        top: topCm,
        left: margenCm,
        child: pw.SizedBox(
          width: anchoItem * PdfPageFormat.cm,
          child: pw.Text(
            articulo['correlativo']?.toString() ?? "",
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
      ),
      _posCm(
        top: topCm,
        left: margenCm + anchoItem,
        child: pw.SizedBox(
          width: anchoType * PdfPageFormat.cm,
          child: pw.Text(
            articulo['tipo'] ?? "",
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
      ),
      _posCm(
        top: topCm,
        left: margenCm + anchoItem + anchoType,
        child: pw.SizedBox(
          width: anchoArticle * PdfPageFormat.cm,
          child: pw.Text(
            articulo['descripcion'] ?? "",
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
      ),
      _posCm(
        top: topCm,
        left: margenCm + anchoItem + anchoType + anchoArticle,
        child: pw.Text(
          articulo['estado'] ?? "",
          style: pw.TextStyle(fontSize: 9),
        ),
      ),
    ];
  }
}
