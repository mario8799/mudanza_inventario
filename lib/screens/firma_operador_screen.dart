import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import 'firma_cliente_screen.dart';

class FirmaOperadorScreen extends StatefulWidget {
  final int inventarioId;

  const FirmaOperadorScreen({
    super.key,
    required this.inventarioId,
  });

  @override
  State<FirmaOperadorScreen> createState() => _FirmaOperadorScreenState();
}

class _FirmaOperadorScreenState extends State<FirmaOperadorScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Future<void> guardarFirma() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe firmar antes de continuar")),
      );
      return;
    }

    Uint8List? data = await _controller.toPngBytes();
    if (data == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final path =
        "${directory.path}/firma_operador_${widget.inventarioId}.png";

    final file = File(path);
    await file.writeAsBytes(data);
    print("Firma guardada en: $path");


    final db = await DatabaseHelper.instance.database;

    await db.update(
      'inventarios',
      {'firmaOperador': path},
      where: 'id = ?',
      whereArgs: [widget.inventarioId],
    );

  final resultado = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FirmaClienteScreen(
      inventarioId: widget.inventarioId,
    ),
  ),
);

if (resultado == true) {
  Navigator.pop(context, true);
};
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firma del Operador")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Por favor firme abajo:",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Signature(controller: _controller),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: guardarFirma,
            child: const Text("Guardar y continuar"),
          ),
          TextButton(
            onPressed: () => _controller.clear(),
            child: const Text("Limpiar"),
          )
        ],
      ),
    );
  }
}
