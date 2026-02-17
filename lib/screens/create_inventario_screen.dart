import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/inventario.dart';
import 'inventario_screen.dart';
import 'dart:math';
import 'package:uuid/uuid.dart'; 

class CreateInventarioScreen extends StatefulWidget {
  // 1. Movemos la variable aquí adentro
  final int? inventarioId; 

  // 2. Insertamos TU línea aquí (reemplazando la anterior):
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

  Future<void> guardarInventario() async {
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
    );

    final id = await db.insert('inventarios', nuevoInventario.toMap());

    if (!mounted) return;

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
                onPressed: guardarInventario,
                child: const Text("Crear Inventario"),
              )
            ],
          ),
        ),
      ),
    );
  }
}