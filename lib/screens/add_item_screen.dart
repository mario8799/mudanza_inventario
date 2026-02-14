import 'package:flutter/material.dart';
import '../models/articulo.dart';

class AddItemScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final int correlativo;
  final Articulo? articuloExistente; // 👈 NUEVO

  const AddItemScreen({
    super.key,
    required this.onSave,
    required this.correlativo,
    this.articuloExistente,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController tipoController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isHighValue = false;

  @override
  void initState() {
    super.initState();

    // 👇 PRECARGAR DATOS SI ES EDICIÓN
    if (widget.articuloExistente != null) {
      final a = widget.articuloExistente!;

      tipoController.text = a.tipo;
      descriptionController.text = a.descripcion;
      roomController.text = a.habitacion;
      conditionController.text = a.estado;
      notesController.text = a.observaciones;
      isHighValue = a.isHighValue == 1;
    }
  }

  void saveItem() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        "tipo": tipoController.text,
        "description": descriptionController.text,
        "room": roomController.text,
        "condition": conditionController.text,
        "notes": notesController.text,
        "isHighValue": isHighValue ? 1 : 0,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.articuloExistente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? "Editar Artículo" : "Agregar Artículo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Correlativo: ${widget.correlativo.toString().padLeft(4, '0')}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: tipoController,
                decoration: const InputDecoration(labelText: "Tipo"),
              ),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),

              TextFormField(
                controller: roomController,
                decoration: const InputDecoration(labelText: "Habitación"),
              ),

              TextFormField(
                controller: conditionController,
                decoration: const InputDecoration(labelText: "Estado"),
              ),

              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Observaciones"),
              ),

              const SizedBox(height: 16),

              CheckboxListTile(
                title: Text(
                  "High Value",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                value: isHighValue,
                onChanged: (value) {
                  setState(() {
                    isHighValue = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveItem,
                child: Text(esEdicion ? "Actualizar" : "Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
