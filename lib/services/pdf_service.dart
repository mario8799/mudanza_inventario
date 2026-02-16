import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

// ... imports igual ...

class PdfService {
  static Future<void> generarPdf({
    required Map<String, dynamic> inventario,
    required List<Map<String, dynamic>> articulos,
    String tipo = "NORMAL",
  }) async {
    final pdf = pw.Document();

    Uint8List? firmaOperador;
    Uint8List? firmaCliente;

    if (inventario['firmaOperador'] != null) {
      firmaOperador = await File(inventario['firmaOperador']).readAsBytes();
    }
    if (inventario['firmaCliente'] != null) {
      firmaCliente = await File(inventario['firmaCliente']).readAsBytes();
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
            angle: 0.5, // Un poco de inclinación
            child: pw.Text(
              "PROGEAR",
              style: pw.TextStyle(
                fontSize: 100, // Un poco más grande
                color: PdfColors.grey100, // Más suave para que no tape el texto
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // --- ENCABEZADO ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            tipo == "HV" ? "DECLARACIÓN DE ALTO VALOR" : "INVENTARIO DE MUDANZA",
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: tipo == "HV" ? PdfColors.red900 : PdfColors.blue900,
                            ),
                          ),
                          if (tipo == "HV")
                            pw.Text("AVISO: Tratamiento especial requerido",
                                style: pw.TextStyle(fontSize: 8, color: PdfColors.red)),
                          pw.SizedBox(height: 10),
                          pw.Text("Número: ${inventario['numeroInventario']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text("Cliente: ${inventario['nombreCliente']} ${inventario['apellidoCliente']}"),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  
                  // --- ARTÍCULOS ---
                  pw.Text(tipo == "PROGEAR" ? "LISTADO DE EQUIPO PROFESIONAL" : "LISTADO DE ARTÍCULOS",
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  ...articulos.map((a) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        child: pw.Text(
                          "${a['correlativo'].toString().padLeft(4, '0')} - ${a['descripcion']} ${tipo == "HV" ? "[ALTO VALOR]" : ""}",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      )),
                  
                  pw.SizedBox(height: 30),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 20),

                  // --- FIRMAS (Aquí es donde se usan las variables) ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      if (firmaOperador != null)
                        pw.Column(children: [
                          pw.Image(pw.MemoryImage(firmaOperador), height: 60, width: 100),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 1))),
                            padding: const pw.EdgeInsets.only(top: 5),
                            child: pw.Text("Firma Operador", textAlign: pw.TextAlign.center),
                          ),
                        ]),
                      if (firmaCliente != null)
                        pw.Column(children: [
                          pw.Image(pw.MemoryImage(firmaCliente), height: 60, width: 100),
                          pw.Container(
                            width: 150,
                            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 1))),
                            padding: const pw.EdgeInsets.only(top: 5),
                            child: pw.Text("Firma Cliente", textAlign: pw.TextAlign.center),
                          ),
                        ]),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}