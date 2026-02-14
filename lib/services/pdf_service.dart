import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generarPdf({
    required Map<String, dynamic> inventario,
    required List<Map<String, dynamic>> articulos,
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
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // --- ENCABEZADO ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "INVENTARIO DE MUDANZA",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text("Número: ${inventario['numeroInventario']}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text("Cliente: ${inventario['nombreCliente']} ${inventario['apellidoCliente']}"),
                  pw.Text("Teléfono: ${inventario['telefonoCliente']}"),
                  pw.Text("Origen: ${inventario['direccionOrigen']}"),
                  pw.Text("Destino: ${inventario['direccionDestino']}"),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("MUDANZAS ELITE S.A.",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text("Av. Siempre Viva 742"),
                  pw.Text("contacto@mudanzaselite.com"),
                  pw.Text("+54 11 4444-5555"),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 10),

          // --- ARTÍCULOS ---
          pw.Text("LISTADO DE ARTÍCULOS",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),

          ...articulos.map((a) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(
                  "${a['correlativo'].toString().padLeft(4, '0')} - ${a['descripcion']}",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              )),

          pw.SizedBox(height: 30),
          pw.Divider(thickness: 1, color: PdfColors.grey300),

          // --- FIRMAS (CORREGIDO) ---
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              if (firmaOperador != null)
                pw.Column(
                  children: [
                    pw.Image(pw.MemoryImage(firmaOperador), height: 60, width: 100),
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 1))),
                      padding: const pw.EdgeInsets.only(top: 5), // <--- CAMBIO AQUÍ
                      child: pw.Text("Firma Operador", textAlign: pw.TextAlign.center),
                    ),
                  ],
                ),
              if (firmaCliente != null)
                pw.Column(
                  children: [
                    pw.Image(pw.MemoryImage(firmaCliente), height: 60, width: 100),
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 1))),
                      padding: const pw.EdgeInsets.only(top: 5), // <--- CAMBIO AQUÍ
                      child: pw.Text("Firma Cliente", textAlign: pw.TextAlign.center),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}