import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfService {

  static Future<void> generarPdf({
    required String nombreArchivo,
    required Map<String, dynamic> inventario,
    required List<Map<String, dynamic>> articulos,
    String tipo = "NORMAL",
    String? nombreOperador,
    String? nombreCliente,

  }) async {

    final pdf = pw.Document();

    Uint8List? firmaOperador;
    Uint8List? firmaCliente;

    if (inventario['firmaOperador'] != null) {
      firmaOperador =
          await File(inventario['firmaOperador']).readAsBytes();
    }

    if (inventario['firmaCliente'] != null) {
      firmaCliente =
          await File(inventario['firmaCliente']).readAsBytes();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Stack(
            children: [
              if (tipo == "PROGEAR")
                pw.Positioned.fill(
                  child: pw.Center(
                    child: pw.Transform.rotate(
                      angle: 0.5,
                      child: pw.Text(
                        "PROGEAR",
                        style: pw.TextStyle(
                          fontSize: 100,
                          color: PdfColors.grey100,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [

                  // ================= ENCABEZADO =================
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            tipo == "HV"
                                ? "DECLARACIÓN DE ALTO VALOR"
                                : "INVENTARIO DE MUDANZA",
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: tipo == "HV"
                                  ? PdfColors.red900
                                  : PdfColors.blue900,
                            ),
                          ),
                          if (tipo == "HV")
                            pw.Text(
                              "AVISO: Tratamiento especial requerido",
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.red),
                            ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            "Número: ${inventario['numeroInventario']}",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            "Cliente: ${inventario['nombreCliente']} ${inventario['apellidoCliente']}",
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),

                  // ================= TÍTULO =================
                  pw.Text(
                    tipo == "PROGEAR"
                        ? "LISTADO DE EQUIPO PROFESIONAL"
                        : "LISTADO DE ARTÍCULOS",
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold),
                  ),

                  pw.SizedBox(height: 10),

                  // ================= TABLA =================
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey600,
                      width: 0.5,
                    ),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(60),  // Correlativo
                      1: const pw.FixedColumnWidth(50),  // Tipo
                      2: const pw.FlexColumnWidth(2),    // Descripción
                      3: const pw.FixedColumnWidth(70),  // Estado
                      4: const pw.FlexColumnWidth(2),    // Observaciones
                    },
                    children: [

                      // ---------- ENCABEZADOS ----------
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _headerCell("Correlativo"),
                          _headerCell("Tipo"),
                          _headerCell("Descripción"),
                          _headerCell("Estado"),
                          _headerCell("Observaciones"),
                        ],
                      ),

                      // ---------- FILAS ----------
                      ...articulos.map((a) {

  final esHV = a['isHighValue'] == 1 || a['isHighValue'] == true;

  final observacionesTexto = a['observaciones'] ?? "";

  final observacionesFinal = esHV
      ? "[HV],  $observacionesTexto"
      : observacionesTexto;

  return pw.TableRow(
    children: [

      _bodyCell(
        a['correlativo']
            .toString()
            .padLeft(4, '0'),
      ),

      _bodyCell(
        a['tipo'] ?? "",
      ),

      _bodyCell(
        a['descripcion'] ?? "",
      ),

      _bodyCell(
        a['estado'] ?? "",
      ),

      _bodyCell(
        observacionesFinal,
        isHV: esHV,
      ),
    ],
  );
}).toList(),

                    ],
                  ),

                  pw.SizedBox(height: 30),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 20),

                  // ================= FIRMAS =================
                  pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
  children: [

    if (firmaOperador != null)
      pw.Column(
        children: [

          pw.Image(
            pw.MemoryImage(firmaOperador),
            height: 80,
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            nombreOperador ?? "",
            style: const pw.TextStyle(fontSize: 10),
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            "Firma Operador",
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),

    if (firmaCliente != null)
      pw.Column(
        children: [

          pw.Image(
            pw.MemoryImage(firmaCliente),
            height: 80,
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            nombreCliente ?? "",
            style: const pw.TextStyle(fontSize: 10),
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            "Firma Cliente",
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),

  ],
),

                ],
              ),
            ],
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: nombreArchivo,
    );
  }

  // ================= CELDAS =================

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _bodyCell(String text, {bool isHV = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
              isHV ? pw.FontWeight.bold : pw.FontWeight.normal,
          color:
              isHV ? PdfColors.red800 : PdfColors.black,
        ),
      ),
    );
  }
}
