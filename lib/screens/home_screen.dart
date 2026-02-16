import 'package:flutter/material.dart';
import 'create_inventario_screen.dart';
import 'buscar_inventario_screen.dart';
import 'eliminados_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateInventarioScreen(),
            ),
          );
        },
        child: const Text("CREAR INVENTARIO"),
      ),

      const SizedBox(height: 20),

      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BuscarInventarioScreen(),
            ),
          );
        },
        child: const Text("BUSCAR INVENTARIO"),
      ),
    const SizedBox(height: 20),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const InventariosEliminadosScreen(),
      ),
    );
  },
  child: const Text("DELETED"),
),


    ],
  ),
),
    );
  }
}
