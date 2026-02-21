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
    required String nombreOperador, // ya llega como parámetro
    Uint8List? firmaOperador,
    Uint8List? firmaCliente,
    required DateTime fechaInventario,
  }) async {

    // ✅ Tomamos los valores directamente
    final codigoInventario = inventario['numeroInventario']?.toString() ?? '';
    final String nombre = inventario['nombreCliente'] ?? '';
    final String apellido = inventario['apellidoCliente'] ?? '';
    final String shipperName = "$nombre $apellido".trim();

    final pdf = pw.Document();

    // 🔹 Elegir plantilla
    String templatePath;

if (tipo == "PROGEAR") {
  templatePath = "assets/pdfs/progear_inventory.png";
} else if (tipo == "HV") {
  templatePath = "assets/pdfs/high_value_inventory.png"; // <-- tu nuevo PNG
} else {
  templatePath = "assets/pdfs/normal_inventory.png";
}

final templateBytes = await rootBundle.load(templatePath);
final template = pw.MemoryImage(templateBytes.buffer.asUint8List());


    final totalArticulos = articulos.length;

    const double margenCm = 1.6;
    const double headerTopCm = 3;
    double primeraFilaTopCm;
    double altoFilaCm;

    double anchoItem;
    double anchoType;
    double anchoArticle;

if (tipo == "HV") {
  altoFilaCm = 0.5;
} else {
  altoFilaCm = 0.42;
}    

if (tipo == "HV") {
  primeraFilaTopCm = 10.77; // 🔥 AJUSTA según tu template HV
  anchoItem = 1.7;
  anchoType = 2.0;        // ejemplo más ancho
  anchoArticle = 2.0;    // ejemplo más angosto
} else {
  primeraFilaTopCm = 9.72;
  anchoItem = 1.2;
  anchoType = 1.4;
  anchoArticle = 11.2;
}

    // 🔹 Dividir en páginas de 30 filas
    List<List<Map<String, dynamic>>> paginas = [];
    int filasPorPagina = tipo == "HV" ? 16 : 30;

for (int i = 0; i < articulos.length; i += filasPorPagina) {
  paginas.add(
    articulos.sublist(
      i,
      i + filasPorPagina > articulos.length
          ? articulos.length
          : i + filasPorPagina,
    ),
  );
}
    if (paginas.isEmpty) paginas.add([]);

    for (int pagina = 0; pagina < paginas.length; pagina++) {
      final articulosPagina = paginas[pagina];
      
      // ✅ CALCULAR RANGO DE ARTÍCULOS PARA EL ENCABEZADO
      final String desde = articulosPagina.isNotEmpty 
          ? articulosPagina.first['correlativo'].toString() 
          : "0";
      final String hasta = articulosPagina.isNotEmpty 
          ? articulosPagina.last['correlativo'].toString() 
          : "0";

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Stack(
              children: [

                // Fondo del formulario
                pw.Positioned.fill(
                  child: pw.Image(template, fit: pw.BoxFit.fill),
                ),

                // 🔹 HEADER

                // Agent / Operador
               _posCm(
                top: headerTopCm, 
                left: 13.2,
                child: pw.Text(
                    "$nombreOperador",
                style: const pw.TextStyle(fontSize: 9),
                  ),
                ),

                // ✅ ARTICLES FROM ____ TO ____
                _posCm(
                  top: headerTopCm - 0.79, // Ajustado para que caiga sobre la línea de "Articles from"
                  left: tipo == "HV" ? 15 : 14.2,
                  child: pw.Text(
                    desde,
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                _posCm(
                  top: headerTopCm - 0.79, // Ajustado para que caiga sobre la línea después de "To:"
                  left: tipo == "HV" ? 17 : 16.7,
                  child: pw.Text(
                    hasta,
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),

                // Shipper’s Name
                _posCm(
                  top: 4.1,
                  left: 4,
                  child: pw.Text(
                    shipperName,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),

                // Código inventario
                _posCm(
                  top: headerTopCm - 0.79,
                  left: tipo == "HV" ? 9.5 : 8.5,
                  child: pw.Text(
                    " $codigoInventario",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),

                // Empresa
                _posCm(
                  top: headerTopCm,
                  left: tipo == "HV" ? margenCm + 0.5 : margenCm,
                  child: pw.Text(
                    "Cornerstone Moving & Storage",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),

                // Direcciones
                _posCm(
                  top: headerTopCm + 2.1,
                  left: 4,
                  child: pw.Text(
                    inventario['direccionOrigen'] ?? "",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                _posCm(
                  top: headerTopCm + 3.1,
                  left: 4,
                  child: pw.Text(
                    inventario['direccionDestino'] ?? "",
                    style: const pw.TextStyle(fontSize: 9),
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
                    tipo,
                  ),

                // 🔹 TOTAL (Solo en la última página)
                if (pagina == paginas.length - 1 && tipo != "HV")
                  _posCm(
                    top: 22.23,
                    left: 9.5,
                    child: pw.Text(
                      totalArticulos.toString(),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),

                // 🔹 FIRMAS y FECHAS
                if (firmaOperador != null && firmaOperador.isNotEmpty)
                  _posCm(
                    top: tipo == "HV" ? 24 : 23.5,
                    left: 3,
                    child: pw.Image(
                      pw.MemoryImage(firmaOperador),
                      width: 2 * PdfPageFormat.cm,
                      height: 1 * PdfPageFormat.cm,
                    ),
                  ),

                if (firmaCliente != null)
                  _posCm(
                    top: tipo == "HV" ? 25.5 : 25,
                    left: 3,
                    child: pw.Image(
                      pw.MemoryImage(firmaCliente),
                      width: 2 * PdfPageFormat.cm,
                      height: 1 * PdfPageFormat.cm,
                    ),
                  ),

                // Fecha Operador
                _posCm(
                  top: tipo == "HV" ? 24.3 : 23.8,
                  left: tipo == "HV" ? 8.9 : 8.6,
                  child: pw.Text(
                    DateFormat('dd/MM/yyyy').format(fechaInventario),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),

                // Fecha Cliente
                _posCm(
                  top: tipo == "HV" ? 25.8 : 25.3,
                  left: tipo == "HV" ? 8.9 : 8.6,
                  child: pw.Text(
                    DateFormat('dd/MM/yyyy').format(fechaInventario),
                    style: const pw.TextStyle(fontSize: 9),
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
  static String _buildEstadoConHV(
    Map<String, dynamic> articulo,
    String tipo,
) {
  final estado = articulo['estado']?.toString() ?? "";

  // Solo mostrar etiqueta HV en NORMAL y PROGEAR
  if (tipo != "HV" && articulo['is_high_value'] == 1) {
    return "$estado, [HV]";
  }

  return estado;
}
  static List<pw.Widget> _buildFila(
  Map<String, dynamic> articulo,
  double topCm,
  double margenCm,
  double anchoItem,
  double anchoType,
  double anchoArticle,
  String tipo,
) {
    return tipo == "HV"
    ? [
        // NO.
        _posCm(
          top: topCm,
          left: margenCm,
          child: pw.Text(
            articulo['correlativo']?.toString() ?? "",
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),

        // ARTICLE (tipo + descripcion)
        _posCm(
          top: topCm,
          left: margenCm + anchoItem,
          child: pw.SizedBox(
            width: 6 * PdfPageFormat.cm,
            child: pw.Text(
              "${articulo['tipo'] ?? ""} ${articulo['descripcion'] ?? ""}",
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ),

        // DESCRIPTION (condition)
        _posCm(
          top: topCm,
          left: margenCm + anchoItem + 4,
          child: pw.SizedBox(
            width: 3 * PdfPageFormat.cm,
            child: pw.Text(
              articulo['estado'] ?? "",
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ),

        // SEAL NO.
        _posCm(
          top: topCm,
          left: margenCm + anchoItem + 9,
          child: pw.Text(""),
        ),

        // REMARKS
        _posCm(
          top: topCm,
          left: margenCm + anchoItem + 11,
          child: pw.Text(""),
        ),
      ]
    : [
        // 👇 Layout NORMAL (el que ya tenías)
        _posCm(
          top: topCm,
          left: margenCm,
          child: pw.SizedBox(
            width: anchoItem * PdfPageFormat.cm,
            child: pw.Text(
              articulo['correlativo']?.toString() ?? "",
              style: const pw.TextStyle(fontSize: 9),
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
              style: const pw.TextStyle(fontSize: 9),
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
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ),
       _posCm(
  top: topCm,
  left: margenCm + anchoItem + anchoType + anchoArticle,
  child: pw.Text(
    _buildEstadoConHV(articulo, tipo),
    style: const pw.TextStyle(fontSize: 9),
  ),
),
      ];
  }
  
}