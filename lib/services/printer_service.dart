import 'package:flutter/services.dart';
import '../models/articulo.dart';

class PrinterService {
  static const MethodChannel _channel =
      MethodChannel('printer_channel');

  static Future<void> printArticulo({
    required Articulo articulo,
    required Map<String, dynamic> inventario,
  }) async {

    final numeroInventario =
        inventario['numeroInventario']
            .toString()
            .padLeft(4, '0');

    final correlativo =
        articulo.correlativo
            .toString()
            .padLeft(4, '0');

    final codigoUnico = "$numeroInventario-$correlativo";

    final cliente =
        "${inventario['nombreCliente']} ${inventario['apellidoCliente']}";

    final destino =
        inventario['direccionDestino'] ?? "";

    String etiqueta = "";
    if (articulo.tipo == "HV") {
      etiqueta = "   [HV]";
    } else if (articulo.tipo == "PROGEAR") {
      etiqueta = "   [PG]";
    }

    final labelText = '''
CORNERSTONE MOVING & STORAGE$etiqueta
--------------------------------
$codigoUnico

$cliente
$destino
''';

    await _channel.invokeMethod("printLabel", {
      "text": labelText,
    });
  }
}
