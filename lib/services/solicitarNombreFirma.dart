import 'package:flutter/material.dart';

Future<String?> solicitarNombreFirma(BuildContext context, String titulo) async {
  TextEditingController controller = TextEditingController();

  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nombre y Apellido",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text("Continuar"),
          ),
        ],
      );
    },
  );
}