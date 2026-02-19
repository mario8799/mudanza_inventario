import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {

  static Future<void> generarPdf({
    required Map<String, dynamic> inventario,
    required List<Map<String, dynamic>> articulos,
    required String tipo, // "NORMAL", "HV", "PROGEAR"
    required String nombreArchivo,
    String? nombreOperador,
    String? nombreCliente,
  }) async {

    final codigoInventario = inventario['numeroInventario']?.toString() ?? '';
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
          i + 30 > articulos.length
              ? articulos.length
              : i + 30,
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

                pw.Positioned.fill(
                  child: pw.Image(
                    template,
                    fit: pw.BoxFit.fill,
                  ),
                ),

                // 🔹 HEADER

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
                  top: headerTopCm,
                  left: 13,
                  child: pw.Text(
                    nombreOperador ?? "",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),

                _posCm(
                  top: headerTopCm + 1.1,
                  left: margenCm,
                  child: pw.Text(
                    nombreCliente ?? inventario['nombreCliente'] ?? "",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),

                _posCm(
                  top: headerTopCm + 2.1,
                  left: margenCm,
                  child: pw.Text(
                    inventario['direccionOrigen'] ?? "",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),

                _posCm(
                  top: headerTopCm + 3.1,
                  left: margenCm,
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
                    top: 22.8,
                    left: 8.5,
                    child: pw.Text(
                      totalArticulos.toString(),
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

    // 🔥 Compartir usando printing (NO share_plus)
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
