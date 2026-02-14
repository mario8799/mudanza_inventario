import 'package:flutter/services.dart';
import '../models/articulo.dart';

class PrinterService {
  static const MethodChannel _channel =
      MethodChannel('printer_channel');

  static Future<void> printArticulo(Articulo articulo) async {
    final labelText = '''
Inventario
#${articulo.correlativo.toString().padLeft(4, '0')}

${articulo.tipo}
${articulo.descripcion}
''';

    await _channel.invokeMethod("printLabel", {
      "text": labelText,
    });
  }
}
