import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';

class FirmaClienteScreen extends StatefulWidget {
  final int inventarioId;

  const FirmaClienteScreen({
    super.key,
    required this.inventarioId,
  });

  @override
  State<FirmaClienteScreen> createState() => _FirmaClienteScreenState();
}

class _FirmaClienteScreenState extends State<FirmaClienteScreen> {
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
        "${directory.path}/firma_cliente_${widget.inventarioId}.png";

    final file = File(path);
    await file.writeAsBytes(data);

    final db = await DatabaseHelper.instance.database;

    await db.update(
      'inventarios',
      {
        'firmaCliente': path,
        'fechaCierre': DateTime.now().toIso8601String(),
        'activo': 0,
      },
      where: 'id = ?',
      whereArgs: [widget.inventarioId],
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firma del Cliente")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Firma de conformidad del cliente:",
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
            child: const Text("Finalizar Inventario"),
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
