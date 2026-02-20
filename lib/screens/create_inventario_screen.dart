import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/inventario.dart';
import 'inventario_screen.dart';
import 'dart:math';
import 'package:uuid/uuid.dart'; 
import '../services/solicitarNombreFirma.dart';
import '../services/pdf_service.dart'; // 🔹 Asegúrate de importar PdfService

class CreateInventarioScreen extends StatefulWidget {
  final int? inventarioId; 
  const CreateInventarioScreen({super.key, this.inventarioId});

  @override
  State<CreateInventarioScreen> createState() => _CreateInventarioScreenState();
}

class _CreateInventarioScreenState extends State<CreateInventarioScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionOrigenController = TextEditingController();
  final TextEditingController direccionDestinoController = TextEditingController();

  String generarNumeroInventario() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> crearInventarioConOperador() async {
    // 1️⃣ Pedir nombre del operador
    final nombreOperador = await solicitarNombreFirma(
      context,
      "Ingrese nombre del Operador",
    );

    if (nombreOperador == null) return; // Canceló

    // 2️⃣ Guardar inventario en DB y obtener el ID
    await guardarInventario(nombreOperador: nombreOperador);
  }

  Future<void> guardarInventario({required String nombreOperador}) async {
    if (!_formKey.currentState!.validate()) return;

    final db = await DatabaseHelper.instance.database;

    final uuidGenerator = Uuid();
    final numeroGenerado = generarNumeroInventario();
    final ahora = DateTime.now().toIso8601String();

    final nuevoInventario = Inventario(
      uuid: uuidGenerator.v4(),
      numeroInventario: numeroGenerado,
      nombreCliente: nombreController.text,
      apellidoCliente: apellidoController.text,
      telefonoCliente: telefonoController.text,
      direccionOrigen: direccionOrigenController.text,
      direccionDestino: direccionDestinoController.text,
      fechaCreacion: ahora,
      fechaActualizacion: ahora,
      activo: 1,
      nombreOperador: nombreOperador,
    );

    // Insertamos en la DB
    final id = await db.insert('inventarios', nuevoInventario.toMap());

    if (!mounted) return;

    // 🔹 Opcional: Generar PDF inmediatamente y pasar nombreOperador
    // Aquí puedes pasar cualquier lista de artículos y tipo de PDF que quieras
    await PdfService.generarPdf(
      inventario: nuevoInventario.toMap(),
      articulos: [], // 🔹 Pon tus artículos reales aquí
      tipo: "NORMAL",
      nombreArchivo: "Inventario_$numeroGenerado.pdf",
      nombreOperador: nombreOperador, // ✅ El operador llega aquí
      fechaInventario: DateTime.now(),
    );

    // Navegar a la pantalla de inventario
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InventarioScreen(
          inventarioId: id,
          numeroInventario: numeroGenerado,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Inventario")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: "Nombre del cliente"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese el nombre" : null,
              ),
              TextFormField(
                controller: apellidoController,
                decoration: const InputDecoration(labelText: "Apellido del cliente"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese el apellido" : null,
              ),
              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: "Teléfono"),
              ),
              TextFormField(
                controller: direccionOrigenController,
                decoration: const InputDecoration(labelText: "Dirección Origen"),
              ),
              TextFormField(
                controller: direccionDestinoController,
                decoration: const InputDecoration(labelText: "Dirección Destino"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: crearInventarioConOperador, // ✅ Llama al método correcto
                child: const Text("Crear Inventario"),
              )
            ],
          ),
        ),
      ),
    );
  }
}